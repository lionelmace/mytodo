##############################################################################
## ICD Postgres
##############################################################################
resource "ibm_database" "icd_postgres" {
  name              = format("%s-%s", var.prefix, "postgres")
  service           = "databases-for-postgresql"
  plan              = var.icd_postgres_plan
  version           = var.icd_postgres_db_version
  service_endpoints = var.icd_postgres_service_endpoints
  location          = var.region
  resource_group_id = local.resource_group_id
  tags              = var.tags

  # Encrypt DB (comment to use IBM-provided Automatic Key)
  # key_protect_instance      = ibm_resource_instance.key-protect.id
  # key_protect_key           = ibm_kms_key.key.id
  # backup_encryption_key_crn = ibm_kms_key.key.id
  # depends_on = [ # require when using encryption key otherwise provisioning failed
  #   ibm_iam_authorization_policy.postgres-kms,
  # ]

  # DB Settings
  adminpassword = var.icd_postgres_adminpassword
  group {
    group_id = "member"

    memory {
      allocation_mb = var.icd_postgres_ram_allocation
    }

    disk {
      allocation_mb = var.icd_postgres_disk_allocation
    }

    cpu {
      allocation_count = var.icd_postgres_core_allocation
    }
  }
}

## IAM
##############################################################################
# Doc at https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-iam
resource "ibm_iam_access_group_policy" "iam-postgres" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Editor"]

  resources {
    service           = "databases-for-postgresql"
    resource_group_id = local.resource_group_id
  }
}

# ## VPE (Optional)
# ##############################################################################
# # VPE can only be created once Postgres DB is fully registered in the backend
# resource "time_sleep" "wait_for_postgres_initialization" {
#   # count = tobool(var.use_vpe) ? 1 : 0

#   depends_on = [
#     ibm_database.icd_postgres
#   ]

#   create_duration = "5m"
# }

# # VPE (Virtual Private Endpoint) for Postgres
# ##############################################################################
# # Make sure your Cloud Databases deployment's private endpoint is enabled
# # otherwise you'll face this error: "Service does not support VPE extensions."
# ##############################################################################
# resource "ibm_is_virtual_endpoint_gateway" "vpe_postgres" {
#   name           = "${var.prefix}-postgres-vpe"
#   resource_group = local.resource_group_id
#   vpc            = ibm_is_vpc.vpc.id

#   target {
#     crn           = ibm_database.icd_postgres.id
#     resource_type = "provider_cloud_service"
#   }

#   # one Reserved IP for per zone in the VPC
#   dynamic "ips" {
#     for_each = { for subnet in ibm_is_subnet.subnet : subnet.id => subnet }
#     content {
#       subnet = ips.key
#       name   = "${ips.value.name}-ip"
#     }
#   }

#   depends_on = [
#     time_sleep.wait_for_postgres_initialization
#   ]

#   tags = var.tags
# }

# data "ibm_is_virtual_endpoint_gateway_ips" "postgres_vpe_ips" {
#   gateway = ibm_is_virtual_endpoint_gateway.vpe_postgres.id
# }

# output "postgres_vpe_ips" {
#   value = data.ibm_is_virtual_endpoint_gateway_ips.postgres_vpe_ips
# }


# Variables
##############################################################################
variable "icd_postgres_plan" {
  type        = string
  description = "The plan type of the Database instance"
  default     = "standard"
}

variable "icd_postgres_adminpassword" {
  type        = string
  description = "The admin user password for the instance"
  default     = "Passw0rd01"
}

variable "icd_postgres_ram_allocation" {
  type        = number
  description = "RAM (GB/data member)"
  default     = 1024
}

variable "icd_postgres_disk_allocation" {
  type        = number
  description = "Disk Usage (GB/data member)"
  default     = 20480
}

variable "icd_postgres_core_allocation" {
  type        = number
  description = "Dedicated Cores (cores/data member)"
  default     = 0
}

variable "icd_postgres_db_version" {
  default     = "12"
  type        = string
  description = "The database version to provision if specified"
}

variable "icd_postgres_users" {
  default     = null
  type        = set(map(string))
  description = "Database Users. It is set of username and passwords"
}

variable "icd_postgres_service_endpoints" {
  default     = "public"
  type        = string
  description = "Types of the service endpoints. Possible values are 'public', 'private', 'public-and-private'."
}