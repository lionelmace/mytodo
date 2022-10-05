##############################################################################
## Secrets Manager
##############################################################################
resource "ibm_resource_instance" "secrets-manager" {
  name              = "${var.prefix}-secrets-manager"
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id
  tags              = var.tags
  service_endpoints = "private"
}