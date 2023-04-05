
##############################################################################
# OpenShift cluster
##############################################################################


# OpenShift Variables
##############################################################################

variable "openshift_cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = "roks"
}

variable "openshift_version" {
  description = "The OpenShift version that you want to set up in your cluster."
  type        = string
  default     = "4.12.3_openshift"
}

variable "openshift_worker_pool_flavor" {
  description = " The flavor of the VPC worker node that you want to use."
  type        = string
  default     = "bx2.4x16"
}

variable "openshift_worker_nodes_per_zone" {
  description = "The number of worker nodes per zone in the default worker pool."
  type        = number
  default     = 1
}

variable "worker_labels" {
  description = "Labels on all the workers in the default worker pool."
  type        = map(any)
  default     = null
}

variable "openshift_wait_till" {
  description = "specify the stage when Terraform to mark the cluster creation as completed."
  type        = string
  default     = "OneWorkerNodeReady"

  validation {
    error_message = "`openshift_wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition = contains([
      "MasterNodeReady",
      "OneWorkerNodeReady",
      "IngressReady"
    ], var.openshift_wait_till)
  }
}

variable "disable_public_service_endpoint" {
  description = "Boolean value true if Public service endpoint to be disabled."
  type        = bool
  default     = false
}

variable "openshift_force_delete_storage" {
  description = "force the removal of persistent storage associated with the cluster during cluster deletion."
  type        = bool
  default     = true
}

variable "kms_config" {
  type    = list(map(string))
  default = []
}

variable "entitlement" {
  description = "Enable openshift entitlement during cluster creation ."
  type        = string
  default     = "cloud_pak"
}

variable "openshift_update_all_workers" {
  description = "OpenShift version of the worker nodes is updated."
  type        = bool
  default     = true
}


# OpenShift Cluster
##############################################################################

module "vpc_openshift_cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/vpc-openshift"

  vpc_id             = ibm_is_vpc.vpc.id
  resource_group_id  = local.resource_group_id
  cluster_name       = format("%s-%s", var.prefix, var.openshift_cluster_name)
  worker_pool_flavor = var.openshift_worker_pool_flavor
  worker_zones = {
    "${var.region}-1" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 0) },
    "${var.region}-2" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 1) },
    "${var.region}-3" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 2) },
  }
  worker_nodes_per_zone           = var.openshift_worker_nodes_per_zone
  kube_version                    = var.openshift_version
  worker_labels                   = var.worker_labels
  wait_till                       = var.openshift_wait_till
  disable_public_service_endpoint = var.disable_public_service_endpoint
  cos_instance_crn                = ibm_resource_instance.cos.id
  force_delete_storage            = var.openshift_force_delete_storage
  kms_config = [
    {
      instance_id      = ibm_resource_instance.key-protect.guid, # GUID of Key Protect instance
      crk_id           = ibm_kms_key.key.key_id,                 # ID of customer root key
      private_endpoint = true
    }
  ]
  entitlement        = var.entitlement
  tags               = var.tags
  update_all_workers = var.openshift_update_all_workers
}

##############################################################################
# Log and Monitoring can only be attached once cluster is fully ready
# resource "time_sleep" "wait_for_openshift_initialization" {

#   depends_on = [
#     module.vpc_openshift_cluster
#   ]

#   create_duration = "15m"
# }

##############################################################################
# Attach Log Analysis Service to cluster
# 
# Integrating Logging requires the master node to be 'Ready'
# If not, you will face a timeout error after 45mins
##############################################################################
module "openshift_logdna_attach" {

  source = "terraform-ibm-modules/cluster/ibm//modules/configure-logdna"

  cluster            = module.vpc_openshift_cluster.vpc_openshift_cluster_id
  logdna_instance_id = module.logging_instance.guid
  private_endpoint   = var.logdna_private_endpoint

  # depends_on = [
  #   time_sleep.wait_for_openshift_initialization
  # ]
}

##############################################################################
# Attach Monitoring Service to cluster
# 
# Integrating Monitoring requires the master node to be 'Ready'
# If not, you will face a timeout error after 45mins
##############################################################################
module "openshift_sysdig_attach" {

  source = "terraform-ibm-modules/cluster/ibm//modules/configure-sysdig-monitor"

  cluster            = module.vpc_openshift_cluster.vpc_openshift_cluster_id
  sysdig_instance_id = module.monitoring_instance.guid
  private_endpoint   = var.sysdig_private_endpoint

  # depends_on = [
  #   time_sleep.wait_for_openshift_initialization
  # ]
}
