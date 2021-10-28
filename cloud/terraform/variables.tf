##############################################################################
# Account Variables
##############################################################################

variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
}

variable prefix {
    description = "A unique identifier need to provision resources. Must begin with a letter"
    type        = string
    default     = ""
}

variable region {
  description = "IBM Cloud region where all resources will be provisioned"
  default     = ""
}

variable resource_group {
  description = "Name of resource group where all infrastructure will be provisioned"
  default     = ""

  validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
    }
}

variable "tags" {
  description = "List of Tags"
  type        = list(string)
  default     = [ "tf", "mytodo" ]
}


##############################################################################
# VPC Variables
##############################################################################

variable "create_vpc" {
  description = "True to create new VPC. False if VPC is already existing and subnets or address prefixies are to be added"
  type        = bool
  default     = true
}

variable "classic_access" {
  description = "Classic Access to the VPC"
  type        = bool
  default     = null
}

variable "default_address_prefix" {
  description = "Default address prefix creation method"
  type        = string
  default     = null
}

variable "default_network_acl_name" {
  description = "Name of the Default ACL"
  type        = string
  default     = null
}

variable "default_security_group_name" {
  description = "Name of the Default Security Group"
  type        = string
  default     = null
}

variable "default_routing_table_name" {
  description = "Name of the Default Routing Table"
  type        = string
  default     = null
}

variable "address_prefixes" {
  description = "List of Prefixes for the vpc"
  type = list(object({
    name     = string
    location = string
    ip_range = string
  }))
  default = []
}

variable "locations" {
  description = "zones per region"
  type        = list(string)
  default     = []
}

variable "number_of_addresses" {
  description = "Number of IPV4 Addresses"
  type        = number
  default     = null
}

variable "vpc" {
  description = "ID of the Existing VPC to which subnets, gateways are to be attached"
  type        = string
  default     = null
}

variable "subnet_access_control_list" {
  description = "Network ACL ID"
  type        = string
  default     = null
}

variable "routing_table" {
  description = "Routing Table ID"
  type        = string
  default     = null
}

variable "create_gateway" {
  description = "True to create new Gateway"
  type        = bool
  default     = true
}

variable "public_gateway_name" {
  description = "Prefix to the names of Public Gateways"
  type        = string
  default     = ""
}

variable "floating_ip" {
  description = "Floating IP `id`'s or `address`'es that you want to assign to the public gateway"
  type        = map
  default     = {}
}


##############################################################################
# Kubernetes Cluster
##############################################################################

variable kubernetes_cluster_name {
  description = "name for the iks cluster"
  default     = ""
}

variable  kubernetes_worker_pool_flavor {
    description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
    type        = string
    default     = "bx2.4x16"
}

# variable "kubernetes_worker_zones" {
#   type    = map
#   default = {}
# }

variable kubernetes_worker_nodes_per_zone {
  description = "Number of workers to provision in each subnet"
  type        = number
  default     = 1
}

variable kubernetes_version {
  description = "Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`."
  type        = string
  default     = "1.22.2"
}

variable kubernetes_wait_till {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
  type        = string
  default     = "MasterNodeReady"

  validation {
    error_message = "`kubernetes_wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition     = contains([
        "MasterNodeReady",
        "OneWorkerNodeReady",
        "IngressReady"
    ], var.kubernetes_wait_till)
  }
}

# variable disable_public_service_endpoint {}
variable "kubernetes_force_delete_storage" {
  description = "force the removal of persistent storage associated with the cluster during cluster deletion."
  type        = bool
  default     = true
}

# variable kms_config {}


##############################################################################
# VPC OpenShift cluster provisioning
##############################################################################

variable "openshift_cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = ""
}

variable "openshift_worker_pool_flavor" {
  description = " The flavor of the VPC worker node that you want to use."
  type        = string
  default     = "bx2.4x16"
}

variable "openshift_version" {
  description = "The OpenShift version that you want to set up in your cluster."
  type        = string
  default     = ""
}

# variable "update_all_workers" {
#   description = "set to true, the Kubernetes version of the worker nodes is updated along with the Kubernetes version of the cluster that you specify in kube_version."
#   type        = bool
#   default     = false
# }

# variable "service_subnet" {
#   description = "Specify a custom subnet CIDR to provide private IP addresses for services."
#   type        = string
#   default     = null
# }

# variable "pod_subnet" {
#   description = "Specify a custom subnet CIDR to provide private IP addresses for pods."
#   type        = string
#   default     = null
# }

variable "openshift_worker_nodes_per_zone" {
  description = "The number of worker nodes per zone in the default worker pool."
  type        = number
  default     = 1
}

variable "worker_labels" {
  description = "Labels on all the workers in the default worker pool."
  type        = map
  default     = null
}

variable "openshift_wait_till" {
  description = "specify the stage when Terraform to mark the cluster creation as completed."
  type        = string
  default     = "MasterNodeReady"

  validation {
    error_message = "`openshift_wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition     = contains([
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

# variable "cos_instance_crn" {
#   description = "Enable openshift entitlement during cluster creation ."
#   type        = string
#   default     = null
# }

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


##############################################################################
# COS Service
##############################################################################
variable "cos_plan" {
  description = "COS plan type"
  type        = string
}

variable "cos_region" {
  description = " Enter Region for provisioning"
  type        = string
}


##############################################################################
# Module: Log Services
##############################################################################
variable "logdna_plan" {
  description = "plan type (14-day, 30-day, 7-day, hipaa-30-day and lite)"
  type        = string
}

variable "logdna_service_endpoints" {
  description = "Types of the service endpoints. Possible values are 'public', 'private', 'public-and-private'."
  type        = string
  default     = "private"
}

variable "logdna_role" {
  description = "Type of role"
  type        = string
  default     = "Administrator"
}

variable "logdna_bind_resource_key" {
  description = "Flag indicating that key should be bind to logdna instance"
  type        = bool
  default     = true
}

variable "logdna_resource_key_name" {
  description = "Name of the instance key"
  type        = string
  default     = "log-ingestion-key"
}

##############################################################################
# Module: Configure Log Services
##############################################################################
variable "logdna_private_endpoint" {
  description = "Add this option to connect to your LogDNA service instance through the private service endpoint"
  type        = bool
  default     = true
}


##############################################################################
# Monitoring Services
##############################################################################
variable "sysdig_plan" {
  description = "plan type"
  type        = string
}
# variable "parameters" {
#   type        = map(string)
#   description = "Arbitrary parameters to pass"
#   default     = null
# }
variable "sysdig_service_endpoints" {
  description = "Types of the service endpoints. Possible values are 'public', 'private', 'public-and-private'."
  type        = string
  default     = "private"
}

variable "sysdig_bind_resource_key" {
  description = "Enable this to bind key to logdna instance (true/false)"
  type        = bool
  default     = true
}

variable "sysdig_resource_key_name" {
  description = "Name of the instance key"
  type        = string
  default     = "sysdig-ingestion-key"
}
variable "sysdig_role" {
  description = "plan type"
  type        = string
  default     = "Administrator"
}


##############################################################################
# Module: Configure Log Services
##############################################################################
variable "sysdig_private_endpoint" {
  description = "Add this option to connect to your Sysdig service instance through the private service endpoint"
  type        = bool
  default     = true
}


##############################################################################
# ICD Mongo Services
##############################################################################
variable "icd_mongo_plan" {
  type        = string
  description = "The plan type of the Database instance"
}
variable "icd_mongo_adminpassword" {
  default     = null
  type        = string
  description = "The admin user password for the instance"
}
variable "icd_mongo_db_version" {
  default     = null
  type        = string
  description = "The database version to provision if specified"
}
variable "icd_mongo_users" {
  default     = null
  type        = set(map(string))
  description = "Database Users. It is set of username and passwords"
}
variable "icd_mongo_whitelist" {
  default     = null
  type        = set(map(string))
  description = "Database Whitelist It is set of IP Address and description"
}
variable "icd_mongo_service_endpoints" {
  default     = null
  type        = string
  description = "Types of the service endpoints. Possible values are 'public', 'private', 'public-and-private'."
}