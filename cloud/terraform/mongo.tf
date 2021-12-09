##############################################################################
## ICD Mongo
##############################################################################
module "database_mongo" {
  source = "terraform-ibm-modules/database/ibm//modules/mongo"

  resource_group_id     = ibm_resource_group.resource_group.id
  service_name          = "${var.prefix}-mongo"
  plan                  = var.icd_mongo_plan
  location              = var.region
  adminpassword         = var.icd_mongo_adminpassword
  database_version      = var.icd_mongo_db_version
  tags                  = var.tags
  service_endpoints     = var.icd_mongo_service_endpoints
  kms_instance          = ibm_resource_instance.key-protect.id
  disk_encryption_key   = ibm_kp_key.key.key_id
  backup_encryption_key = ibm_kp_key.key.key_id
  depends_on = [ # require when using encryption key otherwise provisioning failed
    ibm_iam_authorization_policy.mongo-kms,
  ]

  # memory_allocation                    = var.memory_allocation
  # disk_allocation                      = var.disk_allocation
  # cpu_allocation                       = var.cpu_allocation
  # backup_id                            = var.backup_id
  # remote_leader_id                     = var.remote_leader_id
  # point_in_time_recovery_deployment_id = var.point_in_time_recovery_deployment_id
  # point_in_time_recovery_time          = var.point_in_time_recovery_time
  # users                                = var.users
  # whitelist                            = var.whitelist
  # cpu_rate_increase_percent            = var.cpu_rate_increase_percent
  # cpu_rate_limit_count_per_member      = var.cpu_rate_limit_count_per_member
  # cpu_rate_period_seconds              = var.cpu_rate_period_seconds
  # cpu_rate_units                       = var.cpu_rate_units
  # disk_capacity_enabled                = var.disk_capacity_enabled
  # disk_free_space_less_than_percent    = var.disk_free_space_less_than_percent
  # disk_io_above_percent                = var.disk_io_above_percent
  # disk_io_enabled                      = var.disk_io_enabled
  # disk_io_over_period                  = var.disk_io_over_period
  # disk_rate_increase_percent           = var.disk_rate_increase_percent
  # disk_rate_limit_mb_per_member        = var.disk_rate_limit_mb_per_member
  # disk_rate_period_seconds             = var.disk_rate_period_seconds
  # disk_rate_units                      = var.disk_rate_units
  # memory_io_above_percent              = var.memory_io_above_percent
  # memory_io_enabled                    = var.memory_io_enabled
  # memory_io_over_period                = var.memory_io_over_period
  # memory_rate_increase_percent         = var.memory_rate_increase_percent
  # memory_rate_limit_mb_per_member      = var.memory_rate_limit_mb_per_member
  # memory_rate_period_seconds           = var.memory_rate_period_seconds
  # memory_rate_units                    = var.memory_rate_units
}