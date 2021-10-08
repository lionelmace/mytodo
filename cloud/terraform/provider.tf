##############################################################################
# IBM Cloud Provider
# > Remove for use in schematics
##############################################################################

terraform {
  required_version = ">= 1.0.8"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "~>1.31.0"
    }
  }
  # experiments = [module_variable_optional_attrs]
}

provider ibm {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = 60
}

##############################################################################