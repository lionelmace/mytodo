
##############################################################################
# Monitoring Services
##############################################################################

module "monitoring_instance" {
  source = "terraform-ibm-modules/observability/ibm//modules/monitoring-sysdig"

  resource_group_id = ibm_resource_group.resource_group.id
  name              = "${var.prefix}-monitoring"
  plan              = var.sysdig_plan
  service_endpoints = var.sysdig_service_endpoints
  bind_key          = var.sysdig_bind_key
  key_name          = var.sysdig_key_name
  # role              = var.sysdig_role
  region            = var.region
  tags              = var.tags
  key_tags          = var.tags
}


##############################################################################
# Configure Sysdic Cloud Monitoring Services to an existing cluster
##############################################################################
module "kubernetes_sysdig_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-sysdig-monitor"

  cluster            = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
  sysdig_instance_id = module.monitoring_instance.guid
  private_endpoint   = var.sysdig_private_endpoint
}

module "openshift_sysdig_attach" {
  source = "terraform-ibm-modules/cluster/ibm//modules/configure-sysdig-monitor"

  cluster            = module.vpc_openshift_cluster.vpc_openshift_cluster_id
  sysdig_instance_id = module.monitoring_instance.guid
  private_endpoint   = var.sysdig_private_endpoint
}
