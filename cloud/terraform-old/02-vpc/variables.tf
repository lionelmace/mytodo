##############################################################################
# Sensitive Account Variables
##############################################################################

variable ibmcloud_api_key {
    description = "IBM Cloud IAM API Key"
}

variable resource_group {
    description = "Name of resource group to provision resources"
    default     = "wireguard"
}


##############################################################################
# Account Variables
##############################################################################

variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    default     = "eu-de"
}

variable unique_id {
    description = "Prefix for all resources created in the module. Must begin with a letter."
    default     = "wireguard"
}

variable tags {
    description = "A list of tags for resources created"
    default     = ["terraform", "wireguard"]
}


##############################################################################
# VPC variables
##############################################################################

variable generation {
    description = "VPC generation. Version 2 is recommended."
    default     = 2
}

variable number_of_zones {
    description = "Number of Availability Zones within a MZR."
    default     = 2
}

variable classic_access {
    description = "VPC Classic Access"
    default     = false
}

variable enable_public_gateway {
  description = "Enable public gateways, true or false"
  default     = true
}


##############################################################################
# Network variables
##############################################################################

variable acl_rules {
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

variable prefix_cidr_blocks {
    description = "List of CIDR blocks for the subnets"
    type        = list
    default     = [
        "10.10.0.0/18", 
        "10.20.0.0/18", 
        "10.30.0.0/18"
    ]  
}

variable subnet_cidr_blocks {
    description = "List of CIDR blocks for the subnets"
    type        = list
    default     = [
        "10.10.0.0/24", 
        "10.20.0.0/24", 
        "10.30.0.0/24"
    ]  
}


##############################################################################
# Security Group variables
##############################################################################

variable sg_rules {
    default = [
        # {
        #     # Default SG Rules
        #     "direction": "outbound",
        #     "ip_version": "ipv4",
        #     "port_max": 0,
        #     "port_min": 0,
        #     "protocol": "all",
        #     "remote": "0.0.0.0/0"
        # },
        # {
        #     # Default SG Rules
        #     "direction": "inbound",
        #     "ip_version": "ipv4",
        #     "port_max": 0,
        #     "port_min": 0,
        #     "protocol": "all",
        #     "remote": "r010-7583779d-560c-4826-92e0-4b341375dc9e"
        # },
        {
            # Required by IKS to allow inbound traffic 
            # to ports 30000 - 32767 of your worker nodes
            "direction": "inbound",
            "ip_version": "ipv4",
            "port_max": 32767,
            "port_min": 30000,
            "protocol": "tcp",
            "remote": "0.0.0.0/0"
        }
    ]
}

##############################################################################