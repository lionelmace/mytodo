##############################################################################
# Log Analysis Services
##############################################################################

module "logdna_instance" {
  source = "terraform-ibm-modules/observability/ibm//modules/logging-logdna"

  resource_group_id = ibm_resource_group.resource_group.id
  service_name      = "${var.prefix}-logs"
  service_endpoints = var.logdna_service_endpoints
  bind_resource_key = var.logdna_bind_resource_key
  resource_key_name = var.logdna_resource_key_name
  role              = var.logdna_role
  plan              = var.logdna_plan
  region            = var.region
  tags              = var.tags
  resource_key_tags = var.tags
}


##############################################################################
# Attach Log Analysis Services to an existing cluster
##############################################################################
module "kubernetes_logdna_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-logdna"

  cluster            = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
  logdna_instance_id = module.logdna_instance.logdna_instance_guid
  private_endpoint   = var.logdna_private_endpoint
}

module "openshift_logdna_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-logdna"

  cluster            = module.vpc_openshift_cluster.vpc_openshift_cluster_id
  logdna_instance_id = module.logdna_instance.logdna_instance_guid
  private_endpoint   = var.logdna_private_endpoint
}

