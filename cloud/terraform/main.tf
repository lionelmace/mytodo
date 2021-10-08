
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
  address_prefixes            = var.address_prefixes
  locations                   = var.locations
  subnet_name                 = var.subnet_name
  number_of_addresses         = var.number_of_addresses
  vpc                         = var.vpc
  create_gateway              = var.create_gateway
  # public_gateway_name         = var.public_gateway_name
  floating_ip                 = var.floating_ip
  gateway_tags                = var.tags
}


##############################################################################
# Kubernetes cluster
##############################################################################

# module "vpc_kubernetes_cluster" {
#   source = "terraform-ibm-modules/cluster/ibm//modules/vpc-kubernetes"
#   cluster_name                    = var.cluster_name
#   vpc_id                          = "module.vpc.vpc_id"
#   worker_pool_flavor              = var.worker_pool_flavor
#   worker_zones                    = var.worker_zones
#   worker_nodes_per_zone           = var.worker_nodes_per_zone
#   resource_group_id               = ibm_resource_group.resource_group.id
#   kube_version                    = var.kube_version
#   # update_all_workers              = var.update_all_workers
#   wait_till                       = var.wait_till
#   # disable_public_service_endpoint = var.disable_public_service_endpoint
#   tags                            = var.tags
#   # cos_instance_crn                = var.cos_instance_crn
#   # force_delete_storage            = var.force_delete_storage
#   # kms_config                      = var.kms_config

#   depends_on = [
#     module.vpc,
#   ]
# }
