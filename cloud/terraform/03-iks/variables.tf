##############################################################################
# Sensitive Account Variables
##############################################################################

variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
}

##############################################################################


##############################################################################
# Account Variables
##############################################################################

variable ibm_region {
  description = "IBM Cloud region where all resources will be deployed"
  default     = "eu-de"
}

variable resource_group {
  description = "Name of resource group to provision resources"
  default     = "wireguard"
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable generation {
    description = "VPC generation. Version 2 is recommended."
    default     = 2
}

variable vpc_name {
  description = "ID of VPC where cluster is to be created"
  default     = "wireguard-vpc"
}


##############################################################################
# Cluster Variables
##############################################################################

variable cluster_name {
  description = "name for the iks cluster"
  default     = "wireguard-cluster"
}

variable machine_type {
  description = "Machine type for the IKS Cluster"
  default     = "cx2.2x4"
}


variable worker_count {
  description = "Number of workers per zone"
  default     = 1
}

variable disable_pse {
  description = "Disable public service endpoint for cluster. True or false"
  default     = false
}

variable enable_albs {
  description = "Enable ALBs for cluster"
  default     = true
}

variable only_private_albs {
  description = "enable only private albs"
  default     = false
}

##############################################################################


##############################################################################
# Worker Pool Variables
# > Uncomment to add a worker pool in `optional_assets.tf`
##############################################################################
/*
variable worker_pool_name {
  description = "Worker pool name"
  default     = "worker-pool-2"
}
variable pool_worker_count {
  description = "Count for workers in worker pool"
  default     = 1
}
*/
##############################################################################


##############################################################################
# ALB Cert Name
# > Uncomment to add ALB Cert module in `optional_assets.tf`
##############################################################################
/*
variable alb_cert_name {
  description = "Alb Cert Name"
  default     = "imported-alb-cert"
}
*/
##############################################################################