
##############################################################################
# OpenShift cluster
##############################################################################

module "vpc_openshift_cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/vpc-openshift"

  # vpc_id             = module.vpc.vpc_id[0] # module-vpc
  vpc_id             = ibm_is_vpc.vpc.id
  resource_group_id  = ibm_resource_group.resource_group.id
  cluster_name       = var.openshift_cluster_name
  worker_pool_flavor = var.openshift_worker_pool_flavor
  worker_zones = {
    "${var.region}-1" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 0) },
    "${var.region}-2" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 1) },
    # "${var.region}-3" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 2) },
  }
  /* module-vpc
  worker_zones = {
    "${var.region}-1" = { subnet_id = module.vpc.subnet_ids[0] },
    "${var.region}-2" = { subnet_id = module.vpc.subnet_ids[1] },
    "${var.region}-3" = { subnet_id = module.vpc.subnet_ids[2] }
  }*/
  worker_nodes_per_zone           = var.openshift_worker_nodes_per_zone
  kube_version                    = var.openshift_version
  worker_labels                   = var.worker_labels
  wait_till                       = var.openshift_wait_till
  disable_public_service_endpoint = var.disable_public_service_endpoint
  cos_instance_crn                = module.cos.cos_instance_id
  force_delete_storage            = var.openshift_force_delete_storage
  kms_config = [
    {
      instance_id      = ibm_resource_instance.kp_instance.guid, # GUID of Key Protect instance
      crk_id           = ibm_kp_key.my_kp_key.key_id,            # ID of customer root key
      private_endpoint = true
    }
  ]
  entitlement = var.entitlement
  tags        = var.tags
}