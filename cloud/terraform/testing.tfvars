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
## IAM
##############################################################################
# access_groups=[ { name = "admin" description = "An example admin group" policies = [ { name = "admin_all" resources = { resource_group = "gcat-landing-zone-dev" } roles = ["Administrator","Manager"] } ] dynamic_policies = [] invite_users = [ "test@test.test" ] }, { name = "dev" description = "A developer access group" policies = [ { name = "dev_view_vpc" resources = { resource_group = "gcat-landing-zone-dev" service = "id" } roles = ["Viewer"] } ] invite_users = ["test@test.test"] } ]


##############################################################################
## VPC Version 1.1.1
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
create_gateway = false
# Something with those values for next release
# subnets = {
#     zone-1 = [ { name = "subnet-a" cidr = "10.10.10.0/24" public_gateway = true } ],
#     zone-2 = [ { name = "subnet-b" cidr = "10.20.10.0/24" public_gateway = true } ],
#     zone-3 = [ { name = "subnet-c" cidr = "10.30.10.0/24" public_gateway = true } ] 
# }


##############################################################################
## Cluster
##############################################################################
cluster_name="mytodo-cluster"
worker_pool_flavor="bx2.4x16"
worker_nodes_per_zone=1
entitlement="cloud_pak"
kube_version="1.22.2"
wait_till="IngressReady"
# worker_pools=[ { name = "dev" machine_type = "cx2.8x16" workers_per_zone = 2 }, { name = "test" machine_type = "mx2.4x32" workers_per_zone = 2 } ]


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