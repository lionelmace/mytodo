##############################################################################
# Log Analysis Services
##############################################################################

module "logging_instance" {
  source = "terraform-ibm-modules/observability/ibm//modules/logging-instance"

  resource_group_id    = ibm_resource_group.resource_group.id
  name                 = "${var.prefix}-logs"
  is_sts_instance      = false
  service_endpoints    = var.logdna_service_endpoints
  bind_key             = var.logdna_bind_key
  key_name             = var.logdna_key_name
  plan                 = var.logdna_plan
  enable_platform_logs = var.logdna_enable_platform_logs
  region               = var.region
  tags                 = var.tags
  key_tags             = var.tags
  # role              = var.logdna_role
}

output "logdna_instance_id" {
  description = "The ID of the Log Analysis instance"
  value       = module.logging_instance.id
}

## IAM
##############################################################################

resource "ibm_iam_access_group_policy" "iam-logdna" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Manager", "Viewer", "Standard Member"]

  resources {
    service           = "logdna"
    resource_group_id = ibm_resource_group.resource_group.id
  }
}
