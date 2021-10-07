########################################################################################
# 01-Groups  Creates the Access Groups
#
# Depends on:
#
# Requires:
#   See provider.tf
#       variables.tf
#
# Creates: 
#    This file creates the resource group id, the access groups for the roles defined in the lab and 
#    adds the lab user to the access groups.
#       ibm_iam_access_group.labadmin
#       ibm_iam_access_group.labuser
#
# Outputs: 
#  see outputs.tf
#
# References:
#   Resource Group: https://cloud.ibm.com/docs/terraform?topic=terraform-resource-management-data-sources&-access-data-sources#resource-group
#   IBM IAM:        https://cloud.ibm.com/docs/terraform?topic=terraform-iam-resources&-access-data-sources#iam-access-group
########################################################################################


##############################################################################
# This file creates 
# the resource group id
# the access groups for the roles defined in the lab 
#  adds the lab user to the access groups.
##############################################################################

##############################################################################
# Obtain the resource group id using the name
##############################################################################

data ibm_resource_group lab_rg {
    name = var.resource_group
}

##############################################################################
# Create access groups
##############################################################################


resource ibm_iam_access_group labadmin {
  name = "${var.unique_id}-labadmin"
  tags = ["iks-on-vpc"]
}

resource ibm_iam_access_group labuser {
  name = "${var.unique_id}-labuser"
  tags = ["iks-on-vpc"]
}

##############################################################################
# Create IAM service id
##############################################################################

resource ibm_iam_service_id service_id {
  name        = "${var.unique_id}-iks-on-vpc-service-id"
  description = "${var.unique_id} IKS on VPC service ID"
}


##############################################################################
# Add platform role of reader and service role of viewer to labuser group for 
# all services in the lab resource group. Each area of the terraform templates 
# contains blocks that are commented out for this lab. They can be used to
# assign specific policies for each instance.
##############################################################################

  
resource "ibm_iam_access_group_policy" "labuser_viewer_policy" {
  access_group_id = ibm_iam_access_group.labuser.id
  roles        = ["Reader", "Viewer"]
  resources  {
    resource_group_id = data.ibm_resource_group.lab_rg.id
  }
}