##############################################################################
# This file creates the VPC, Zones, subnets and public gateway for the VPC
# a separate file sets up the load balancers, listeners, pools and members
##############################################################################


##############################################################################
# Create a VPC
##############################################################################

resource ibm_is_vpc vpc {
  name                      = "${var.unique_id}-vpc"
  resource_group            = data.ibm_resource_group.resource_group.id
  classic_access            = var.classic_access
  address_prefix_management = "manual"
  tags                      = var.tags
}


##############################################################################
# Create Address Prefixes
##############################################################################

resource ibm_is_vpc_address_prefix prefix {
  count = var.number_of_zones

  name  = "${var.unique_id}-prefix-zone-${count.index + 1}"
  zone  = "${var.ibm_region}-${(count.index % 3) + 1}"
  vpc   = ibm_is_vpc.vpc.id
  cidr  = element(var.prefix_cidr_blocks, count.index)
}


##############################################################################
# Create Public Gateways
##############################################################################

resource ibm_is_public_gateway gateway {
  count = var.number_of_zones

  name  = "${var.unique_id}-gateway-zone-${count.index+1}"
  vpc   = ibm_is_vpc.vpc.id
  zone  = "${var.ibm_region}-${count.index+1}"
}

##############################################################################
# Create Subnets
##############################################################################

resource ibm_is_subnet subnet {
  count = var.number_of_zones

  name            = "${var.unique_id}-subnet-${count.index + 1}"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-${count.index + 1}"
  ipv4_cidr_block = element(var.subnet_cidr_blocks, count.index)
  public_gateway  = element(ibm_is_public_gateway.gateway.*.id, count.index)
  network_acl     = ibm_is_network_acl.multizone_acl.id
  depends_on      = [ibm_is_vpc_address_prefix.prefix]
}

##############################################################################