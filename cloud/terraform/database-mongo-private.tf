##############################################################################
## ICD Mongo
##############################################################################
resource "ibm_database" "icd_mongo_private" {
  name              = format("%s-%s", var.prefix, "mongo-private")
  service           = "databases-for-mongodb"
  plan              = var.icd_mongo_private_plan
  version           = var.icd_mongo_private_db_version
  service_endpoints = var.icd_mongo_private_service_endpoints
  location          = var.region
  resource_group_id = local.resource_group_id
  tags              = var.tags

  # Encrypt DB (comment to use IBM-provided Automatic Key)
  key_protect_instance      = ibm_resource_instance.key-protect.id
  key_protect_key           = ibm_kms_key.key.id
  backup_encryption_key_crn = ibm_kms_key.key.id
  depends_on = [ # require when using encryption key otherwise provisioning failed
    ibm_iam_authorization_policy.mongo-kms,
  ]

  # DB Settings
  adminpassword = var.icd_mongo_private_adminpassword
  group {
    group_id = "member"

    memory {
      allocation_mb = var.icd_mongo_private_ram_allocation
    }

    disk {
      allocation_mb = var.icd_mongo_private_disk_allocation
    }

    cpu {
      allocation_count = var.icd_mongo_private_core_allocation
    }
  }
}

## Service Credentials
##############################################################################
resource "ibm_resource_key" "key" {
  name                 = format("%s-%s", var.prefix, "mongo-private-key")
  resource_instance_id = ibm_database.icd_mongo.id
  role                 = "Viewer"
}

## IAM
##############################################################################
# Doc at https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-iam
# resource "ibm_iam_access_group_policy" "iam-mongo-private" {
#   access_group_id = ibm_iam_access_group.accgrp.id
#   roles           = ["Editor"]

#   resources {
#     service           = "databases-for-postgresql"
#     resource_group_id = local.resource_group_id
#   }
# }


# Variables
##############################################################################
variable "icd_mongo_private_plan" {
  type        = string
  description = "The plan type of the Database instance"
  default     = "standard"
}

variable "icd_mongo_private_adminpassword" {
  type        = string
  description = "The admin user password for the instance"
  default     = "Passw0rd01"
}

variable "icd_mongo_private_ram_allocation" {
  type        = number
  description = "RAM (GB/data member)"
  default     = 1024
}

variable "icd_mongo_private_disk_allocation" {
  type        = number
  description = "Disk Usage (GB/data member)"
  default     = 20480
}

variable "icd_mongo_private_core_allocation" {
  type        = number
  description = "Dedicated Cores (cores/data member)"
  default     = 0
}

variable "icd_mongo_private_db_version" {
  default     = "4.4"
  type        = string
  description = "The database version to provision if specified"
}

variable "icd_mongo_private_users" {
  default     = null
  type        = set(map(string))
  description = "Database Users. It is set of username and passwords"
}

variable "icd_mongo_private_service_endpoints" {
  default     = "private"
  type        = string
  description = "Types of the service endpoints. Possible values are 'public', 'private', 'public-and-private'."
}