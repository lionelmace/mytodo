##############################################################################
## Secrets Manager
##############################################################################
resource "ibm_resource_instance" "secrets-manager" {
  name              = "${var.prefix}-secrets-manager"
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id
  tags              = var.tags
  service_endpoints = "private"

  # Once the cluster is created... create and register this Secrets Manager
  # instance to your cluster
  depends_on = [module.vpc_kubernetes_cluster]
  provisioner "local-exec" {
    command = "ibmcloud ks ingress instance register --cluster ${iks-cluster-crn} --crn ${secrets-manager-crn} --is-default"
  }
}

output "secrets-manager-crn" {
  description = "The CRN of the Secrets Manager instance"
  value       = ibm_resource_instance.secrets-manager.id
}