
module "vpc_kubernetes_cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/vpc-kubernetes"
  cluster_name                    = var.cluster_name
  vpc_id                          = var.vpc_id
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

  # worker_nodes_per_zone           = var.worker_nodes_per_zone
  # resource_group_id               = data.ibm_resource_group.rg.id
  # kube_version                    = var.kube_version
  # update_all_workers              = var.update_all_workers
  # service_subnet                  = var.service_subnet
  # pod_subnet                      = var.pod_subnet
  # worker_labels                   = var.worker_labels
  # wait_till                       = var.wait_till
  # disable_public_service_endpoint = var.disable_public_service_endpoint
  # tags                            = var.tags
  # cos_instance_crn                = var.cos_instance_crn
  # force_delete_storage            = var.force_delete_storage
  # kms_config                      = var.kms_config
  # create_timeout                  = var.create_timeout
  # update_timeout                  = var.update_timeout
  # delete_timeout                  = var.delete_timeout
}

### OLD BELOW


##############################################################################
# Create IKS on VPC Cluster
##############################################################################

# resource ibm_container_vpc_cluster cluster {

#   name               = var.cluster_name
#   vpc_id             = data.ibm_is_vpc.vpc.id
#   flavor             = var.machine_type
#   worker_count       = var.worker_count
#   resource_group_id  = data.ibm_resource_group.resource_group.id
#   kube_version       = "1.18.9"
#   # Lets Terraform start working with the cluster as soon as a node is available
#   wait_till          = "OneWorkerNodeReady"

#   zones {
#     # subnet_id = element(data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids, 0)
#     subnet_id = "02b7-810e14e9-767a-4a5d-9f1b-487e5c7150a4"
#     name      = "${var.ibm_region}-1"
#   }
#   zones {
#     # subnet_id = element(data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids, 1)
#     subnet_id = "02c7-c60eba3b-6cfb-4256-bd4a-d5c3bb90ad71"
#     name      = "${var.ibm_region}-2"
#   }
#   # zones {
#   # #   subnet_id = element(data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids, 2)
#   #   subnet_id = "${data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids[2]}"
#   #   name      = "${var.ibm_region}-3"
#   # }

#   disable_public_service_endpoint = var.disable_pse
# }

##############################################################################


##############################################################################
# Enable Private ALBs, disable public
##############################################################################

# resource ibm_container_vpc_alb alb {
#   count  = "6" 
  
#   alb_id = element(ibm_container_vpc_cluster.cluster.albs.*.id, count.index)
#   enable = "${
#     var.enable_albs && !var.only_private_albs 
#     ? true
#     : var.only_private_albs && element(ibm_container_vpc_cluster.cluster.albs.*.alb_type, count.index) != "public" 
#       ? true
#       : false
#   }"
# }

##############################################################################