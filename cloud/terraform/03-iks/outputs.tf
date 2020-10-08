##############################################################################
# IKS on VPC Outputs
##############################################################################

output cluster_name {
    description = "Name of the IKS on VPC Cluster, only returns after cluster deploys"
    value       = ibm_container_vpc_cluster.cluster.name
}

output cluster_id {
    description = "ID of the IKS on VPC Cluster"
    value       = ibm_container_vpc_cluster.cluster.id
}

##############################################################################