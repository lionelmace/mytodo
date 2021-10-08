##############################################################################
# Account Variables
##############################################################################


variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
}

variable prefix {
    description = "A unique identifier need to provision resources. Must begin with a letter"
    type        = string
    default     = "tf"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
    }
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
  default     = ["tf","mytodo"]
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable "create_vpc" {
  description = "True to create new VPC. False if VPC is already existing and subnets or address prefixies are to be added"
  type        = bool
  default     = true
}

#####################################################
# Optional Parameters
#####################################################

variable "vpc_name" {
  description = "Name of the vpc"
  type        = string
  default     = null
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

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = null
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

variable "public_gateway_name_prefix" {
  description = "Prefix to the names of Public Gateways"
  type        = string
  default     = null
}

variable "floating_ip" {
  description = "Floating IP `id`'s or `address`'es that you want to assign to the public gateway"
  type        = map
  default     = {}
}


##############################################################################
# Cluster
##############################################################################

variable cluster_name {
  description = "name for the iks cluster"
  default     = ""
}

variable  worker_pool_flavor {
    description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
    type        = string
    default     = "bx2.4x16"
}

variable "worker_zones" {
  type    = map
  default = {}
}


variable worker_nodes_per_zone {
  description = "Number of workers to provision in each subnet"
  type        = number
  default     = 1
}

variable entitlement {
    description = "If you purchased an IBM Cloud Cloud Pak that includes an entitlement to run worker nodes that are installed with OpenShift Container Platform, enter entitlement to create your cluster with that entitlement so that you are not charged twice for the OpenShift license. Note that this option can be set only when you create the cluster. After the cluster is created, the cost for the OpenShift license occurred and you cannot disable this charge."
    type        = string
    default     = "cloud_pak"
}

variable kube_version {
  description = "Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`."
  type        = string
  default     = "1.22.2"
}

variable wait_till {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
  type        = string
  default     = "IngressReady"

  validation {
    error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition     = contains([
        "MasterNodeReady",
        "OneWorkerNodeReady",
        "IngressReady"
    ], var.wait_till)
  }
}

# variable disable_public_service_endpoint {}
# variable tags {}
# variable cos_instance_crn {}
# variable force_delete_storage {}
# variable kms_config {}

### OLD

# variable machine_type {
#   description = "Machine type for the IKS Cluster"
#   default     = "cx2.2x4"
# }


# variable worker_count {
#   description = "Number of workers per zone"
#   default     = 1
# }

# variable disable_pse {
#   description = "Disable public service endpoint for cluster. True or false"
#   default     = false
# }

# variable enable_albs {
#   description = "Enable ALBs for cluster"
#   default     = true
# }

# variable only_private_albs {
#   description = "enable only private albs"
#   default     = false
# }

##############################################################################