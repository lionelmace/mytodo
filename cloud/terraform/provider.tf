##############################################################################
# IBM Cloud Provider
# > Remove for use in schematics
##############################################################################

terraform {
  required_version = ">= 1.0.8"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.33.1"
    }
  }
}

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.ibm_region
  # generation            = var.generation
  ibmcloud_timeout      = 60
}

##############################################################################