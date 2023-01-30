
##############################################################################
# Create a resource group or reuse an existing one
##############################################################################

resource "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 0 : 1
  name  = format("%s-%s", var.prefix, "group")
  tags  = var.tags
}

data "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 1 : 0
  name  = var.resource_group_name
}

locals {
  resource_group_id = var.resource_group_name != "" ? data.ibm_resource_group.group.0.id : ibm_resource_group.group.0.id
}

output "resource_group_id" {
  value = local.resource_group_id
}