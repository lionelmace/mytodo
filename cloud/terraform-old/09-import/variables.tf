##############################################################################
# Sensitive Account Variables
##############################################################################

variable ibmcloud_api_key {
    description = "IBM Cloud IAM API Key"
}

variable resource_group {
    description = "Name of resource group to provision resources"
    default     = "rg_toutoui_app_nonprod"
}

##############################################################################


##############################################################################
# Account Variables
##############################################################################

variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    default     = "eu-de"
}

variable unique_id {
    description = "Prefix for all resources created in the module. Must begin with a letter."
    default     = "wireguard"
}

variable tags {
    description = "A list of tags for resources created"
    default     = ["terraform", "wireguard"]
}

##############################################################################


##############################################################################
# VPC variables
##############################################################################

variable generation {
    description = "VPC generation. Version 2 is recommended."
    default     = 2
}

variable number_of_zones {
    description = "Number of Availability Zones within a MZR."
    default     = 2
}