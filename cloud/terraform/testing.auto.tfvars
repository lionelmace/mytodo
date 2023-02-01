##############################################################################
## Global Variables
##############################################################################
#ibmcloud_api_key = ""      # Set the variable export TF_VAR_ibmcloud_api_key=
prefix                = "mytodo"
region                = "eu-de" # eu-de for Frankfurt MZR
resource_group_name   = ""
tags                  = ["terraform", "mytodo"]
activity_tracker_name = "platform-activities"


##############################################################################
## VPC
##############################################################################
vpc_classic_access            = false
vpc_address_prefix_management = "manual"
vpc_enable_public_gateway     = true
# vpc_locations                 = ["eu-de-1", "eu-de-2", "eu-de-3"]
# vpc_number_of_addresses       = 256


##############################################################################
## Cluster Kubernetes
##############################################################################
kubernetes_cluster_name          = "iks"
kubernetes_version               = "1.25.6"
kubernetes_worker_nodes_per_zone = 1
kubernetes_worker_pool_flavor    = "bx2.4x16"
# kubernetes_worker_pool_flavor    = "bx2.16x64" # ODF or Portworx min flavor

# Possible values: MasterNodeReady, OneWorkerNodeReady, or IngressReady
kubernetes_wait_till          = "IngressReady"
kubernetes_update_all_workers = false
# worker_pools=[ { name = "dev" machine_type = "cx2.8x16" workers_per_zone = 2 },
#                { name = "test" machine_type = "mx2.4x32" workers_per_zone = 2 } ]


##############################################################################
## Cluster OpenShift
##############################################################################
openshift_cluster_name       = "roks"
openshift_version            = "4.11.22_openshift"
openshift_worker_pool_flavor = "bx2.4x16"
# openshift_worker_pool_flavor = "bx2.16x64" # ODF Flavors

# Available values: MasterNodeReady, OneWorkerNodeReady, or IngressReady
openshift_wait_till          = "IngressReady"
openshift_update_all_workers = false


##############################################################################
## COS
##############################################################################
cos_plan   = "standard"
cos_region = "global"


##############################################################################
## Observability: Log Analysis (Mezmo) & Monitoring (Sysdig)
##############################################################################
# Available Plans: lite, 7-day, 14-day, 30-day
logdna_plan                 = "7-day"
logdna_enable_platform_logs = false

sysdig_plan                    = "graduated-tier"
sysdig_enable_platform_metrics = false


##############################################################################
## ICD Mongo
##############################################################################
icd_mongo_plan = "enterprise" # standard
# expected length in the range (10 - 32) - must not contain special characters
icd_mongo_adminpassword     = "Passw0rd01"
icd_mongo_db_version        = "4.4"
icd_mongo_service_endpoints = "private"

# Minimum parameter for Enterprise Edition
icd_mongo_ram_allocation = 14336
icd_mongo_disk_allocation = 20480
icd_mongo_core_allocation = 6


# Minimum parameter for Standard Edition
# icd_mongo_ram_allocation = 1024
# icd_mongo_disk_allocation = 20480
# icd_mongo_core_allocation = 0

icd_mongo_users = [{
  name     = "user123"
  password = "password12"
}]
icd_mongo_whitelist = [{
  address     = "172.168.1.1/32"
  description = "desc"
}]
