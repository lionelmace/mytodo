
##############################################################################
# Resource Group where Cloud Resources will be created
##############################################################################

resource ibm_resource_group resource_group {
  name = var.resource_group
}


##############################################################################
# VPC
##############################################################################

module vpc {
  # Limitation of Version 1.1.1
  # https://github.com/terraform-ibm-modules/terraform-ibm-vpc/releases
  # if you want to create custom address prefixes and add subnets to it.. 
  # for now you need to two separate modules (vpc, subnet modules). 
  # In the next release we are targeting this feature… so that only vpc module 
  # would suffice to create custom address prefixes and subnets to it
  version = "1.1.1"
  source = "terraform-ibm-modules/vpc/ibm//modules/vpc"

  create_vpc                  = var.create_vpc
  vpc_name                    = var.vpc_name
  resource_group_id           = ibm_resource_group.resource_group.id
  classic_access              = var.classic_access
  default_address_prefix      = var.default_address_prefix
  default_network_acl_name    = var.default_network_acl_name
  default_security_group_name = var.default_security_group_name
  default_routing_table_name  = var.default_routing_table_name
  vpc_tags                    = var.tags
  # address_prefixes            = var.address_prefixes
  locations                   = var.locations
  subnet_name                 = var.subnet_name
  number_of_addresses         = var.number_of_addresses
  vpc                         = var.vpc
  # Public Gateway required to access the OpenShift Console
  create_gateway              = var.create_gateway
  public_gateway_name         = var.public_gateway_name
  floating_ip                 = var.floating_ip
  gateway_tags                = var.tags
}


##############################################################################
# Kubernetes cluster
##############################################################################

module "vpc_kubernetes_cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/vpc-kubernetes"
  
  vpc_id                          = module.vpc.vpc_id[0]
  resource_group_id               = ibm_resource_group.resource_group.id
  cluster_name                    = var.kubernetes_cluster_name
  worker_pool_flavor              = var.kubernetes_worker_pool_flavor
  worker_zones = {
    "${var.region}-1" = { subnet_id = module.vpc.subnet_ids[0] },
    "${var.region}-2" = { subnet_id = module.vpc.subnet_ids[1] },
    "${var.region}-3" = { subnet_id = module.vpc.subnet_ids[2] }
  }
  worker_nodes_per_zone           = var.kubernetes_worker_nodes_per_zone
  kube_version                    = var.kubernetes_version
  wait_till                       = var.kubernetes_wait_till
  force_delete_storage            = var.kubernetes_force_delete_storage
  tags                            = var.tags
  # kms_config                      = var.kms_config
  # disable_public_service_endpoint = var.disable_public_service_endpoint
  # update_all_workers              = var.update_all_workers
}


##############################################################################
# OpenShift cluster
##############################################################################

module "vpc_openshift_cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/vpc-openshift"

  vpc_id                          = module.vpc.vpc_id[0]
  resource_group_id               = ibm_resource_group.resource_group.id
  cluster_name                    = var.openshift_cluster_name
  worker_pool_flavor              = var.openshift_worker_pool_flavor
  worker_zones = {
    "${var.region}-1" = { subnet_id = module.vpc.subnet_ids[0] },
    "${var.region}-2" = { subnet_id = module.vpc.subnet_ids[1] },
    "${var.region}-3" = { subnet_id = module.vpc.subnet_ids[2] }
  }
  worker_nodes_per_zone           = var.openshift_worker_nodes_per_zone
  kube_version                    = var.openshift_version
  # update_all_workers              = var.update_all_workers
  # service_subnet                  = var.service_subnet
  # pod_subnet                      = var.pod_subnet
  worker_labels                   = var.worker_labels
  wait_till                       = var.openshift_wait_till
  disable_public_service_endpoint = var.disable_public_service_endpoint
  cos_instance_crn                = module.cos.cos_instance_id
  force_delete_storage            = var.openshift_force_delete_storage
  # kms_config                      = var.kms_config
  entitlement                     = var.entitlement
  tags                            = var.tags
}


##############################################################################
# COS Service for OpenShift Internal Registry
##############################################################################

module "cos" {
  source = "terraform-ibm-modules/cos/ibm//modules/instance"

  resource_group_id = ibm_resource_group.resource_group.id
  service_name      = var.cos_service_name
  plan              = var.cos_plan
  region            = var.cos_region
  tags              = var.tags
  key_tags          = var.tags
  # service_endpoints = var.service_endpoints
  # resource_key_name = var.resource_key_name
  # role              = var.role
  # bind_resource_key = var.bind_resource_key
  # key_parameters    = var.key_parameters
}


##############################################################################
# Log Analysis Services
##############################################################################

module "logdna_instance" {
  source  = "terraform-ibm-modules/observability/ibm//modules/logging-logdna"

  resource_group_id   = ibm_resource_group.resource_group.id
  service_name        = var.logdna_service_name
  service_endpoints   = var.logdna_service_endpoints
  bind_resource_key   = var.logdna_bind_resource_key
  resource_key_name   = var.logdna_resource_key_name
  role                = var.logdna_role
  plan                = var.logdna_plan
  region              = var.region
  tags                = var.tags
  resource_key_tags   = var.tags
}


##############################################################################
# Configure Log Analysis Services to an existing cluster
##############################################################################
# Attach to Kubernetes Cluster
module "kubernetes_logdna_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-logdna"

  cluster              = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
  logdna_instance_id   = module.logdna_instance.logdna_instance_guid
  private_endpoint     = var.logdna_private_endpoint
}

# Attach to OpenShift Cluster
module "openshift_logdna_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-logdna"

  cluster              = module.vpc_openshift_cluster.vpc_openshift_cluster_id
  logdna_instance_id   = module.logdna_instance.logdna_instance_guid
  private_endpoint     = var.logdna_private_endpoint
}



##############################################################################
# Monitoring Services
##############################################################################

module "sysdig_instance" {
  source = "terraform-ibm-modules/observability/ibm//modules/monitoring-sysdig"

  resource_group_id = ibm_resource_group.resource_group.id
  service_name      = var.sysdig_service_name
  plan              = var.sysdig_plan
  service_endpoints = var.sysdig_service_endpoints
  bind_resource_key = var.sysdig_bind_resource_key
  resource_key_name = var.sysdig_resource_key_name
  role              = var.sysdig_role
  region            = var.region
  tags              = var.tags
  resource_key_tags = var.tags
}


##############################################################################
# Configure Sysdic Cloud Monitoring Services to an existing cluster
##############################################################################
# Attach to Kubernetes Cluster
module "kubernetes_sysdig_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-sysdig-monitor"

  cluster            = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
  sysdig_instance_id = module.sysdig_instance.sysdig_guid
  private_endpoint   = var.sysdig_private_endpoint
}

# Attach to OpenShift Cluster
module "openshift_sysdig_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-sysdig-monitor"

  cluster            = module.vpc_openshift_cluster.vpc_openshift_cluster_id
  sysdig_instance_id = module.sysdig_instance.sysdig_guid
  private_endpoint   = var.sysdig_private_endpoint
}


##############################################################################
## ICD Mongo
##############################################################################

module "database_mongo" {
  source            = "terraform-ibm-modules/database/ibm//modules/mongo"

  resource_group_id                    = ibm_resource_group.resource_group.id
  service_name                         = var.icd_mongo_name
  plan                                 = var.icd_mongo_plan
  location                             = var.region
  adminpassword                        = var.icd_mongo_adminpassword
  database_version                     = var.icd_mongo_db_version
  tags                                 = var.tags
  # memory_allocation                    = var.memory_allocation
  # disk_allocation                      = var.disk_allocation
  # cpu_allocation                       = var.cpu_allocation
  # service_endpoints                    = var.service_endpoints
  # backup_id                            = var.backup_id
  # remote_leader_id                     = var.remote_leader_id
  # kms_instance                         = var.kms_instance
  # disk_encryption_key                  = var.disk_encryption_key
  # backup_encryption_key                = var.backup_encryption_key
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

##############################################################################
## Key Protect
##############################################################################
/*
resource "ibm_resource_instance" "kp_instance" {
  resource_group_id = ibm_resource_group.resource_group.id
  name              = "key-protect"
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.region
  tags              = var.tags
}

resource "ibm_kp_key" "my_kp_key" {
  key_protect_id  = ibm_resource_instance.kp_instance.guid
  key_name     = "my-key-name"
  standard_key = false
}*/