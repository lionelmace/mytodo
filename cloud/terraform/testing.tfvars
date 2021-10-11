## terraform apply -var-file="testing.tfvars"

##############################################################################
## Global Variables
##############################################################################
# Best is to set the variable export TF_VAR_ibmcloud_api_key=
#ibmcloud_api_key=""
prefix = "tf"
region = "eu-de"
resource_group = "mytodo"
tags = [ "tf", "mytodo" ]


##############################################################################
## VPC
##############################################################################
vpc_name = "mytodo-vpc"
classic_access = false
default_address_prefix = "auto"
# After version 1.1.1, you can use manual to create custom address prefixes 
# and add subnets to it
# default_address_prefix = "manual"
# address_prefixes = [
    # {
    #   name     = "prefix-1"
    #   location = "eu-de-1"
    #   ip_range = "10.40.0.0/18"
    # },
    # {
    #   name     = "prefix-2"
    #   location = "eu-de-2"
    #   ip_range = "10.50.0.0/18"
    # },
    # {
    #   name     = "prefix-3"
    #   location = "eu-de-3"
    #   ip_range = "10.60.0.0/18"
    # }
# ]
locations = [ "eu-de-1", "eu-de-2", "eu-de-3" ]
subnet_name = "mytodo"
number_of_addresses = 256
create_gateway = true
public_gateway_name = "pgw"
# Something with those values for next release
# subnets = {
#     zone-1 = [ { name = "subnet-a" cidr = "10.10.10.0/24" public_gateway = true } ],
#     zone-2 = [ { name = "subnet-b" cidr = "10.20.10.0/24" public_gateway = true } ],
#     zone-3 = [ { name = "subnet-c" cidr = "10.30.10.0/24" public_gateway = true } ] 
# }


##############################################################################
## Cluster Kubernetes
##############################################################################
kubernetes_cluster_name          = "mytodo-cluster"
kubernetes_worker_pool_flavor    = "bx2.4x16"
kubernetes_worker_nodes_per_zone = 1
kubernetes_version               = "1.22.2"
kubernetes_wait_till             = "IngressReady"
# worker_pools=[ { name = "dev" machine_type = "cx2.8x16" workers_per_zone = 2 },
#                { name = "test" machine_type = "mx2.4x32" workers_per_zone = 2 } ]


##############################################################################
## Cluster OpenShift
##############################################################################
openshift_cluster_name       = "mytodo-iro"
openshift_worker_pool_flavor = "bx2.4x16"
openshift_version            = "4.8.11_openshift"


##############################################################################
## COS
##############################################################################
cos_service_name = "mytoro-iro-registry"
cos_plan = "standard"
cos_region = "global"


##############################################################################
## Observability
##############################################################################
logdna_service_name = "mytodo-logs"
logdna_plan         = "30-day"
sysdig_service_name = "mytodo-monitoring"
sysdig_plan         = "graduated-tier-sysdig-secure-plus-monitor"


##############################################################################
## ICD Mongo
##############################################################################
icd_mongo_name              = "mytodo-mongo"
icd_mongo_plan              = "standard"
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

## Multizone VPC
# classic_access=false
# subnets={ 
#     zone-1 = [{ name = "subnet-a", cidr = "10.10.10.0/24", public_gateway = true }], 
#     zone-2 = [{ name = "subnet-b", cidr = "10.20.10.0/24", public_gateway = true }], 
#     zone-3 = [{ name = "subnet-c", cidr = "10.30.10.0/24", public_gateway = true }] 
# }
# use_public_gateways={ 
#     zone-1 = true 
#     zone-2 = true 
#     zone-3 = true 
# }
# acl_rules=[
#     {
#       name        = "allow-all-inbound"
#       action      = "allow"
#       direction   = "inbound"
#       destination = "0.0.0.0/0"
#       source      = "0.0.0.0/0"
#     },
#     {
#       name        = "allow-all-outbound"
#       action      = "allow"
#       direction   = "outbound"
#       destination = "0.0.0.0/0"
#       source      = "0.0.0.0/0"
#     }
#   ]
# security_group_rules=[
#     {
#       name      = "allow-inbound-ping"
#       direction = "inbound"
#       remote    = "0.0.0.0/0"
#       icmp      = {
#         type = 8
#       }
#     },
#     {
#       name      = "allow-inbound-ssh"
#       direction = "inbound"
#       remote    = "0.0.0.0/0"
#       tcp       = {
#         port_min = 22
#         port_max = 22
#       }
#     },
#   ]