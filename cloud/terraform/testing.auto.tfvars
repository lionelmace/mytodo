## terraform apply -var-file="testing.tfvars"

##############################################################################
## Global Variables
##############################################################################
#ibmcloud_api_key = ""      # Set the variable export TF_VAR_ibmcloud_api_key=
prefix         = "mytodo"
region         = "eu-de" # eu-de for Frankfurt MZR
resource_group = "mytodo"
tags           = ["tf", "mytodo"]


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
kubernetes_worker_pool_flavor    = "bx2.4x16"
# kubernetes_worker_pool_flavor    = "bx2.16x64" # ODF or Portworx min flavor
kubernetes_worker_nodes_per_zone = 1
kubernetes_version               = "1.25.5"
# Possible values: MasterNodeReady, OneWorkerNodeReady, or IngressReady
kubernetes_wait_till          = "OneWorkerNodeReady"
kubernetes_update_all_workers = false
# worker_pools=[ { name = "dev" machine_type = "cx2.8x16" workers_per_zone = 2 },
#                { name = "test" machine_type = "mx2.4x32" workers_per_zone = 2 } ]


##############################################################################
## Cluster OpenShift
##############################################################################
openshift_cluster_name       = "iro-odf"
openshift_worker_pool_flavor = "bx2.4x16"
# openshift_worker_pool_flavor = "bx2.16x64" # ODF Flavors
openshift_version = "4.11.17_openshift"

# Available values: MasterNodeReady, OneWorkerNodeReady, or IngressReady
openshift_wait_till          = "OneWorkerNodeReady"
openshift_update_all_workers = false

##############################################################################
## COS
##############################################################################
cos_plan   = "standard"
cos_region = "global"


##############################################################################
## Observability: Log Analysis (LogDNA) & Monitoring (Sysdig)
##############################################################################
# Available Plans: lite, 7-day, 14-day, 30-day
logdna_plan                 = "7-day"
logdna_enable_platform_logs = false

sysdig_plan                    = "graduated-tier-sysdig-secure-plus-monitor"
sysdig_enable_platform_metrics = false


##############################################################################
## ICD Mongo
##############################################################################
icd_mongo_plan = "standard"
# expected length in the range (10 - 32) - must not contain special characters
icd_mongo_adminpassword     = "Passw0rd01"
icd_mongo_db_version        = "4.2"
icd_mongo_service_endpoints = "private"
icd_mongo_users = [{
  name     = "user123"
  password = "password12"
}]
icd_mongo_whitelist = [{
  address     = "172.168.1.1/32"
  description = "desc"
}]
