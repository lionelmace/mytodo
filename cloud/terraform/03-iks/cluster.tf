##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource ibm_container_vpc_cluster cluster {

  name               = var.cluster_name
  vpc_id             = data.ibm_is_vpc.vpc.id
  flavor             = var.machine_type
  worker_count       = var.worker_count
  resource_group_id  = data.ibm_resource_group.resource_group.id
  kube_version       = "1.18.9"
  # Lets Terraform start working with the cluster as soon as a node is available
  wait_till          = "OneWorkerNodeReady"

  zones {
    # subnet_id = element(data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids, 0)
    subnet_id = "02b7-810e14e9-767a-4a5d-9f1b-487e5c7150a4"
    name      = "${var.ibm_region}-1"
  }
  zones {
    # subnet_id = element(data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids, 1)
    subnet_id = "02c7-c60eba3b-6cfb-4256-bd4a-d5c3bb90ad71"
    name      = "${var.ibm_region}-2"
  }
  # zones {
  # #   subnet_id = element(data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids, 2)
  #   subnet_id = "${data.ibm_schematics_output.vpc_workspace.output_values.subnet_ids[2]}"
  #   name      = "${var.ibm_region}-3"
  # }

  disable_public_service_endpoint = var.disable_pse
}

##############################################################################


##############################################################################
# Enable Private ALBs, disable public
##############################################################################

resource ibm_container_vpc_alb alb {
  count  = "6" 
  
  alb_id = element(ibm_container_vpc_cluster.cluster.albs.*.id, count.index)
  enable = "${
    var.enable_albs && !var.only_private_albs 
    ? true
    : var.only_private_albs && element(ibm_container_vpc_cluster.cluster.albs.*.alb_type, count.index) != "public" 
      ? true
      : false
  }"
}

##############################################################################