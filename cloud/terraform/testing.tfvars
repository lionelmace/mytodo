## terraform apply -var-file="testing.tfvars"

##############################################################################
## Global Variables
##############################################################################
# Best is to set the variable export TF_VAR_ibmcloud_api_key=
#ibmcloud_api_key=""
prefix         = "mytodo"
region         = "eu-de"
resource_group = "mytodo"
tags           = ["tf", "mytodo"]


##############################################################################
## VPC
##############################################################################
classic_access = false
# default_address_prefix = "manual" # use by vpc module
address_prefix_management = "manual"
enable_public_gateway     = true
locations                 = ["eu-de-1", "eu-de-2", "eu-de-3"]
number_of_addresses       = 256
# create_gateway            = true # module-vpc
# public_gateway_name       = "pgw" # module-vpc
# Something with those values for next release
# subnets = {
#     zone-1 = [ { name = "subnet-a" cidr = "10.10.10.0/24" public_gateway = true } ],
#     zone-2 = [ { name = "subnet-b" cidr = "10.20.10.0/24" public_gateway = true } ],
#     zone-3 = [ { name = "subnet-c" cidr = "10.30.10.0/24" public_gateway = true } ] 
# }


##############################################################################
## Cluster Kubernetes
##############################################################################
kubernetes_cluster_name          = "iks"
kubernetes_worker_pool_flavor    = "bx2.4x16"
kubernetes_worker_nodes_per_zone = 1
kubernetes_version               = "1.22.2"
kubernetes_wait_till             = "IngressReady"
# worker_pools=[ { name = "dev" machine_type = "cx2.8x16" workers_per_zone = 2 },
#                { name = "test" machine_type = "mx2.4x32" workers_per_zone = 2 } ]


##############################################################################
## Cluster OpenShift
##############################################################################
openshift_cluster_name       = "iro"
openshift_worker_pool_flavor = "bx2.4x16"
openshift_version            = "4.8.14_openshift"


##############################################################################
## COS
##############################################################################
cos_plan   = "standard"
cos_region = "global"


##############################################################################
## Observability: LogDNA & Sysdig
##############################################################################
logdna_plan = "30-day"
sysdig_plan = "graduated-tier-sysdig-secure-plus-monitor"


##############################################################################
## ICD Mongo
##############################################################################
icd_mongo_plan = "standard"
# expected length in the range (10 - 32) - must not contain special characters
icd_mongo_adminpassword     = "Passw0rd01"
icd_mongo_db_version        = "4.2"
icd_mongo_service_endpoints = "public"
icd_mongo_users = [{
  name     = "user123"
  password = "password12"
}]
icd_mongo_whitelist = [{
  address     = "172.168.1.1/32"
  description = "desc"
}]
