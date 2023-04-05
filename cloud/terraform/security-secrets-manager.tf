##############################################################################
## Secrets Manager
##############################################################################
resource "ibm_resource_instance" "secrets-manager" {
  name              = format("%s-%s", var.prefix, "secrets-manager")
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = local.resource_group_id
  tags              = var.tags
  service_endpoints = "private"
}

output "secrets-manager-crn" {
  description = "The CRN of the Secrets Manager instance"
  value       = ibm_resource_instance.secrets-manager.id
}