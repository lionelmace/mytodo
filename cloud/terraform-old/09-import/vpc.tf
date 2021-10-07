##############################################################################
# This file creates the VPC, Zones, subnets and public gateway for the VPC
# a separate file sets up the load balancers, listeners, pools and members
##############################################################################


##############################################################################
# Create a VPC
##############################################################################

resource ibm_is_security_group scurvy-staring-candied-distincted {}


# resource "ibm_is_vpc" "vpc1" {}


# resource "ibm_is_subnet" "subnet1" {}

# resource "ibm_container_vpc_cluster" "cluster" {
#     resource_group_id = data.ibm_resource_group.resource_group.id
# }

