##############################################################################
# IBM Cloud Provider
# > This block needs to be here to use in schematics
##############################################################################

terraform {
  required_version = ">= 0.13.3"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.12.0"
    }
  }
}

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.ibm_region
  generation            = var.generation
  ibmcloud_timeout      = 60
}

##############################################################################


##############################################################################
# Resource Group
##############################################################################

data ibm_resource_group resource_group {
  name    = var.resource_group
}

##############################################################################