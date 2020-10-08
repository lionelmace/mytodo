##############################################################################
# Create an  ACL for ingress/egress used by all subnets in VPC
##############################################################################

resource ibm_is_network_acl multizone_acl {
  
  name = "${var.unique_id}-multizone-acl"
  vpc  = ibm_is_vpc.vpc.id

  dynamic rules {

    for_each = var.acl_rules

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
# Create Default Security Groups
##############################################################################

# resource ibm_is_security_group default_sg {
  
#   name       = "${var.unique_id}-sg"
#   vpc        = ibm_is_vpc.vpc.id
# }

##############################################################################
# Modify default Security Groups to add IKS Rules
##############################################################################

resource ibm_is_security_group_rule default_iks {

  # group     = ibm_is_security_group.default_sg.id
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 30000
    port_max = 32767
  }
}