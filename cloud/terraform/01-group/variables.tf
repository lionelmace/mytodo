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

##############################################################################

variable generation {
    description = "VPC generation. Version 2 is recommended."
    default     = 2
}

variable resource_group {
  default = "tf-demo"
}