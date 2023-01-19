
## Instances
##############################################################################
resource "ibm_resource_instance" "continuous-delivery" {
  resource_group_id = ibm_resource_group.resource_group.id
  name              = "${var.prefix}-continuous-delivery"
  service           = "continuous-delivery"
  plan              = "professional"
  location          = var.region
  tags              = var.tags
}

## IAM
##############################################################################

# DevOps - Continuous Delivery
resource "ibm_iam_access_group_policy" "iam-continuous-delivery" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Manager", "Writer", "Editor", "Operator", "Viewer"]

  resources {
    service           = "continuous-delivery"
    resource_group_id = ibm_resource_group.resource_group.id
  }
}

# DevOps - Toolchain
resource "ibm_iam_access_group_policy" "iam-toolchain" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Editor", "Operator", "Viewer"]

  resources {
    service           = "toolchain"
    resource_group_id = ibm_resource_group.resource_group.id
  }
}
