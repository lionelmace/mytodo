
##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

resource ibm_resource_group resource_group {
  name = var.resource_group
}
##############################################################################


##############################################################################
# Create VPC
##############################################################################

module vpc {
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
  subnet_name_prefix          = var.subnet_name_prefix
  number_of_addresses         = var.number_of_addresses
  vpc                         = var.vpc
  create_gateway              = var.create_gateway
  # public_gateway_name         = var.public_gateway_name
  floating_ip                 = var.floating_ip
  gateway_tags                = var.tags
}

##############################################################################


##############################################################################
# Provision Kubernetes cluster
##############################################################################

module "vpc_kubernetes_cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/vpc-kubernetes"
  cluster_name                    = var.cluster_name
  vpc_id                          = module.vpc.vpc_id
  worker_pool_flavor              = var.worker_pool_flavor
  worker_zones = {
    "${var.ibm_region}-1" = {
      subnet_id = "02b7-b2c7c714-2376-4f55-ba65-fd905eda89ec"
    },
    "${var.ibm_region}-2" = {
      subnet_id = "02c7-7fb23b6d-d24c-4150-ba34-98d1810b4821"
    },
    "${var.ibm_region}-3" = {
      subnet_id = "02d7-f87a9609-4dd0-4d83-bfc7-2d41f4c4cdc5"
    }
  }

  worker_nodes_per_zone           = var.worker_nodes_per_zone
  resource_group_id               = ibm_resource_group.resource_group.id
  kube_version                    = var.kube_version
  # update_all_workers              = var.update_all_workers
  wait_till                       = var.wait_till
  # disable_public_service_endpoint = var.disable_public_service_endpoint
  tags                            = var.tags
  # cos_instance_crn                = var.cos_instance_crn
  # force_delete_storage            = var.force_delete_storage
  # kms_config                      = var.kms_config

  depends_on = [
    module.vpc,
  ]
}
##############################################################################
