

##############################################################################
# VPC Variables
##############################################################################

variable "create_vpc" {
  description = "True to create new VPC. False if VPC is already existing and subnets or address prefixies are to be added"
  type        = bool
  default     = true
}

variable "vpc_classic_access" {
  description = "Classic Access to the VPC"
  type        = bool
  default     = false
}

variable "vpc_address_prefix_management" {
  description = "Default address prefix creation method"
  type        = string
  default     = "manual"
}

variable "vpc_acl_rules" {
  default = [
    {
      name        = "egress"
      action      = "allow"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      direction   = "inbound"
    },
    {
      name        = "ingress"
      action      = "allow"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      direction   = "outbound"
    }
  ]
}

variable "vpc_cidr_blocks" {
  description = "List of CIDR blocks for Address Prefix"
  default = [
    "10.243.0.0/18",
    "10.243.64.0/18",
  "10.243.128.0/18"]
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for subnets"
  default = [
    "10.243.0.0/24",
    "10.243.64.0/24",
  "10.243.128.0/24"]
}

variable "vpc_enable_public_gateway" {
  description = "Enable public gateways, true or false"
  default     = true
}

variable "floating_ip" {
  description = "Floating IP `id`'s or `address`'es that you want to assign to the public gateway"
  type        = map(any)
  default     = {}
}

##############################################################################
# Create a VPC
##############################################################################

resource "ibm_is_vpc" "vpc" {
  name                        = format("%s-%s", var.prefix, "vpc")
  resource_group              = local.resource_group_id
  address_prefix_management   = var.vpc_address_prefix_management
  default_security_group_name = "${var.prefix}-vpc-sg"
  default_network_acl_name    = "${var.prefix}-vpc-acl"
  classic_access              = var.vpc_classic_access
  tags                        = var.tags
}


##############################################################################
# Prefixes and subnets for zone
##############################################################################

resource "ibm_is_vpc_address_prefix" "address_prefix" {

  count = 3
  name  = "${var.prefix}-prefix-zone-${count.index + 1}"
  zone  = "${var.region}-${(count.index % 3) + 1}"
  vpc   = ibm_is_vpc.vpc.id
  cidr  = element(var.vpc_cidr_blocks, count.index)
}


##############################################################################
# Public Gateways
##############################################################################

resource "ibm_is_public_gateway" "pgw" {

  count = var.vpc_enable_public_gateway ? 3 : 0
  name  = "${var.prefix}-pgw-${count.index + 1}"
  vpc   = ibm_is_vpc.vpc.id
  zone  = "${var.region}-${count.index + 1}"

}

# Security Groups
##############################################################################

# Rules required to allow necessary inbound traffic to your cluster (IKS/OCP)
##############################################################################
# To expose apps by using load balancers or Ingress, allow traffic through VPC 
# load balancers. For example, for Ingress listening on TCP/443
resource "ibm_is_security_group_rule" "sg-rule-inbound-icmp" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    type = 8
  }
}

# Allow incoming ICMP packets (Ping)
##############################################################################
resource "ibm_is_security_group_rule" "sg-rule-inbound-https" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

# SSH Inbound Rule
##############################################################################
resource "ibm_is_security_group_rule" "sg-rule-inbound-ssh" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

# CIS Cloudflare IPs
# https://api.cis.cloud.ibm.com/v1/ips
##############################################################################
variable "cis_ips" {
  description = "List of CIS Cloudflare IPs"
  default = [
    "173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22",
    "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18",
    "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22",
    "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13",
  "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
}

resource "ibm_is_security_group" "sg-cis-cloudflare" {
  name = format("%s-%s", var.prefix, "sg-cis-ips")
  vpc  = ibm_is_vpc.vpc.id
  resource_group = local.resource_group_id
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-cloudflare" {
  group     = ibm_is_security_group.sg-cis-cloudflare.id
  count     = 15
  direction = "inbound"
  remote    = element(var.cis_ips, count.index)
  tcp {
    port_min = 443
    port_max = 443
  }
}

# Control Plane IPs
# Source: https://github.com/IBM-Cloud/kube-samples/blob/master/control-plane-ips/control-plane-ips-fra.txt
##############################################################################
variable "control-plane-ips" {
  description = "List of Control Plane IPs"
  default = [
    "149.81.115.96/28", "149.81.128.192/27", "158.177.28.192/27",
    "158.177.66.192/28", "161.156.134.64/28", "161.156.184.32/27", "149.81.104.122"]
}

resource "ibm_is_security_group" "sg-iks-control-plane-fra" {
  name = format("%s-%s", var.prefix, "sg-iks-control-plane-fra")
  vpc  = ibm_is_vpc.vpc.id
  resource_group = local.resource_group_id
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-control-plane" {
  group     = ibm_is_security_group.sg-iks-control-plane-fra.id
  count     = 7
  direction = "inbound"
  remote    = element(var.control-plane-ips, count.index)
}

resource "ibm_is_security_group_rule" "sg-rule-outbound-control-plane" {
  group     = ibm_is_security_group.sg-iks-control-plane-fra.id
  count     = 7
  direction = "outbound"
  remote    = element(var.control-plane-ips, count.index)
  tcp {
    port_min = 80
    port_max = 80
  }
}


##############################################################################

resource "ibm_is_security_group" "kube-master-outbound" {
  name = format("%s-%s", var.prefix, "kube-master-outbound")
  vpc  = ibm_is_vpc.vpc.id
  resource_group = local.resource_group_id
}

resource "ibm_is_security_group_rule" "sg-rule-kube-master-tcp-outbound" {
  group     = ibm_is_security_group.kube-master-outbound.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 30000
    port_max = 32767
  }
}
resource "ibm_is_security_group_rule" "sg-rule-kube-master-udp-outbound" {
  group     = ibm_is_security_group.kube-master-outbound.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 30000
    port_max = 32767
  }
}


##############################################################################
# resource "ibm_is_security_group" "home-access" {
#   name = format("%s-%s", var.prefix, "sg-cis-ips")
#   vpc  = ibm_is_vpc.vpc.id
# }

# resource "ibm_is_security_group_rule" "sg-rule-inbound-cloudflare" {
#   group     = ibm_is_security_group.sg-cis-cloudflare.id
#   count     = 15
#   direction = "inbound"
#   remote    = element(var.cis_ips, count.index)
#   tcp {
#     port_min = 443
#     port_max = 443
#   }
# }
# Attached CIS Security Group to VPC Load Balancer
# variable "alb_id" {
#   description = "VPC Load Balancer"
#   default     = ""
# }

# data "ibm_is_lb" "lb" {
#   count = var.vpc_lb_name != "" ? 1 : 0
#   name  = var.vpc_lb_name
#   alb_id = module.vpc_openshift_cluster.vpc_openshift_cluster_id.albs.id
# }

# output "lb-name" {
#   description = "The VPC LB name"
#   value       = ibm_is_lb.name
# } 

# Network ACLs
##############################################################################
resource "ibm_is_network_acl" "multizone_acl" {

  name           = "${var.prefix}-multizone-acl"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = local.resource_group_id

  dynamic "rules" {

    for_each = var.vpc_acl_rules

    content {
      name        = rules.value.name
      action      = rules.value.action
      source      = rules.value.source
      destination = rules.value.destination
      direction   = rules.value.direction
    }
  }
}


##############################################################################
# Create Subnets
##############################################################################

resource "ibm_is_subnet" "subnet" {

  count = 3
  name  = "${var.prefix}-subnet-${count.index + 1}"
  vpc   = ibm_is_vpc.vpc.id
  zone  = "${var.region}-${count.index + 1}"
  # ipv4_cidr_block = element(ibm_is_vpc_address_prefix.address_prefix.*.cidr, count.index)
  ipv4_cidr_block = element(var.subnet_cidr_blocks, count.index)
  network_acl     = ibm_is_network_acl.multizone_acl.id
  public_gateway  = var.vpc_enable_public_gateway ? element(ibm_is_public_gateway.pgw.*.id, count.index) : null

  depends_on = [ibm_is_vpc_address_prefix.address_prefix]
}