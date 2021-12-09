
# module-vpc
# output "vpc_id" {
#   description = "The ID of the VPC"
#   value       = module.vpc.vpc_id
# }

##############################################################################
# VPC GUID
##############################################################################

output "vpc_id" {
  description = "ID of VPC created"
  value       = ibm_is_vpc.vpc.id
}


##############################################################################
# ACL ID
##############################################################################

output "acl_id" {
  description = "ID of ACL created"
  value       = ibm_is_network_acl.multizone_acl.id
}

output "cos_instance_crn" {
  description = "The CRN of the COS instance"
  value       = module.cos.cos_instance_id
}

output "logdna_instance_id" {
  description = "The ID of the Log Analysis instance"
  value       = module.logging_instance.id
}

output "monitoring_instance_id" {
  description = "The ID of the Cloud Monitoring instance"
  value       = module.monitoring_instance.id
}