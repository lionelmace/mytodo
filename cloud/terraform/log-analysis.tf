##############################################################################
# Log Analysis Services
##############################################################################

module "logging_instance" {
  source = "terraform-ibm-modules/observability/ibm//modules/logging-instance"

  resource_group_id = ibm_resource_group.resource_group.id
  name              = "${var.prefix}-logs"
  is_sts_instance   = false
  service_endpoints = var.logdna_service_endpoints
  bind_key          = var.logdna_bind_key
  key_name          = var.logdna_key_name
  plan              = var.logdna_plan
  enable_platform_logs = var.logdna_enable_platform_logs
  region            = var.region
  tags              = var.tags
  key_tags          = var.tags
  # role              = var.logdna_role
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

module "openshift_logdna_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-logdna"

  cluster            = module.vpc_openshift_cluster.vpc_openshift_cluster_id
  logdna_instance_id = module.logging_instance.guid
  private_endpoint   = var.logdna_private_endpoint
}

