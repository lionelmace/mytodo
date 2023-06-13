
##############################################################################
# Create a resource group or reuse an existing one
##############################################################################

# Name must begin/end with a letter and contain only letters, numbers, and - .
variable "resource_group_name" {
  description = "Name of resource group where all services will be provisioned"
  default     = ""

  # validation {
  #   error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
  #   condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group_name))
  # }
}

resource "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 0 : 1
  name  = format("%s-%s", local.basename, "group")
  tags  = var.tags
}

data "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 1 : 0
  name  = var.resource_group_name
}

locals {
  # resource_group_id = var.resource_group_name != "" ? data.ibm_resource_group.group.0.id : ibm_resource_group.group.0.id
  resource_group_id = var.resource_group_name == "" ? "${var.prefix}-group" : ibm_resource_group.group.0.id
}

output "resource_group_id" {
  value = local.resource_group_id
}