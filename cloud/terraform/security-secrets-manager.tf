##############################################################################
## Secrets Manager
##############################################################################
resource "ibm_resource_instance" "secrets-manager" {
  name              = format("%s-%s", local.basename, "secrets-manager")
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = local.resource_group_id
  tags              = var.tags
  service_endpoints = "private"
}

resource "ibm_sm_secret_group" "sm_secret_group"{
  instance_id   = ibm_resource_instance.secrets-manager.guid
  region        = var.region
  name          = format("%s-%s", local.basename, "sm-group")
  description   = "Secret Group"
}

output "secrets-manager-crn" {
  description = "The CRN of the Secrets Manager instance"
  value       = ibm_resource_instance.secrets-manager.id
}