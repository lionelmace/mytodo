##############################################################################
# Outputs
##############################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "kubernetes_cluster_id" {
  description = "The ID of the Kubernetes cluster"
  value       = module.vpc_kubernetes_cluster.kubernetes_vpc_cluster_id
}

output "openshift_cluster_id" {
  description = "The ID of the OpenShift cluster"
  value       = module.vpc_openshift_cluster.vpc_openshift_cluster_id
}

output "cos_instance_crn" {
  description = "The CRN of the COS instance"
  value       = module.cos.cos_instance_id
}

output "logdna_instance_id" {
  description = "The ID of the Log Analysis"
  value       = module.logdna_instance.logdna_instance_id
}

output "sysdig_instance_id" {
  description = "The ID of the Cloud Monitoring instance"
  value       = module.sysdig_instance.sysdig_id
}