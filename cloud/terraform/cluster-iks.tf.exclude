##############################################################################
# Kubernetes cluster
##############################################################################

module "vpc_kubernetes_cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/vpc-kubernetes"

  vpc_id             = ibm_is_vpc.vpc.id
  resource_group_id  = ibm_resource_group.resource_group.id
  cluster_name       = var.kubernetes_cluster_name
  worker_pool_flavor = var.kubernetes_worker_pool_flavor
  worker_zones = {
    "${var.region}-1" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 0) },
    "${var.region}-2" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 1) },
    "${var.region}-3" = { subnet_id = element(ibm_is_subnet.subnet.*.id, 2) },
  }
  worker_nodes_per_zone = var.kubernetes_worker_nodes_per_zone
  kube_version          = var.kubernetes_version
  wait_till             = var.kubernetes_wait_till
  force_delete_storage  = var.kubernetes_force_delete_storage
  tags                  = var.tags
  kms_config = [
    {
      instance_id      = ibm_resource_instance.key-protect.guid, # GUID of Key Protect instance
      crk_id           = ibm_kp_key.key.key_id,                  # ID of root key
      private_endpoint = true
    }
  ]
  # disable_public_service_endpoint = var.disable_public_service_endpoint
  update_all_workers = var.kubernetes_update_all_workers
}

output "iks_cluster_crn" {
  description = "The CRN of the IKS Cluser"
  value       = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
}

##############################################################################
# Attach Log Analysis Services to cluster
##############################################################################
module "kubernetes_logdna_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-logdna"

  cluster            = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
  logdna_instance_id = module.logging_instance.guid
  private_endpoint   = var.logdna_private_endpoint
}


##############################################################################
# Attach Monitoring Services to cluster
##############################################################################
module "kubernetes_sysdig_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-sysdig-monitor"

  cluster            = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
  sysdig_instance_id = module.monitoring_instance.guid
  private_endpoint   = var.sysdig_private_endpoint
}

# Authorization policy between IKS and Secrets Manager
resource "ibm_iam_authorization_policy" "iks-sm" {
  source_service_name         = "containers-kubernetes"
  source_resource_instance_id = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
  target_service_name         = "secrets-manager"
  target_resource_instance_id = ibm_resource_instance.secrets-manager.guid
  roles                       = ["Manager"]
}

# Attach Secrets Manager to the cluster
# resource "null_resource" "attach-secrets-manager-to-cluster" {

#   triggers = {
#     APIKEY             = var.ibmcloud_api_key
#     REGION             = var.region
#     CLUSTER_ID         = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
#     SECRETS_MANAGER_ID = ibm_resource_instance.secrets-manager.id
#   }

#   provisioner "local-exec" {
#     command = "./attach-secrets-manager.sh"
#     environment = {
#       APIKEY             = self.triggers.APIKEY
#       REGION             = self.triggers.REGION
#       CLUSTER_ID         = self.triggers.CLUSTER_ID
#       SECRETS_MANAGER_ID = self.triggers.SECRETS_MANAGER_ID
#     }
#   }
#   depends_on = [ ibm_iam_authorization_policy.iks-sm, ]
# }