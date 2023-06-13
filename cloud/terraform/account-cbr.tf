# Variables
##############################################################################

# Account ID is required for CBR Rule and Zone
data "ibm_iam_account_settings" "account_settings" {
}

# Resources
##############################################################################

resource "ibm_cbr_zone" "zone_vpc" {
  name       = format("%s-%s", local.basename, "zone-vpc")
  account_id = data.ibm_iam_account_settings.account_settings.account_id
  addresses {
    type  = "vpc"
    value = ibm_is_vpc.vpc.crn
  }
}

resource "ibm_cbr_zone" "zone_home" {
  name       = format("%s-%s", local.basename, "zone-home")
  account_id = data.ibm_iam_account_settings.account_settings.account_id
  addresses {
    type  = "ipAddress"
    value = "62.193.63.110"
  }
}

# Zone with the VPC Public Gateways
##############################################################################
resource "ibm_cbr_zone" "cbr_zone_pgw" {
  name       = format("%s-%s", local.basename, "pgws")
  account_id = data.ibm_iam_account_settings.account_settings.account_id
  addresses {
    type  = "ipAddress"
    value = ibm_is_public_gateway.pgw.0.floating_ip.address
  }
  addresses {
    type  = "ipAddress"
    value = ibm_is_public_gateway.pgw.1.floating_ip.address
  }
  addresses {
    type  = "ipAddress"
    value = ibm_is_public_gateway.pgw.2.floating_ip.address
  }
}

##############################################################################
resource "ibm_cbr_zone" "cbr_zone_cis_ips" {
  name       = format("%s-%s", local.basename, "cis-ips")
  account_id = data.ibm_iam_account_settings.account_settings.account_id

  dynamic "addresses" {
    for_each = var.cis_ips
    content {
      type  = "subnet"
      value = addresses.value
    }
  }
}

# Rules
##############################################################################
# resource "ibm_cbr_rule" "cbr_rule_iks" {
#   description      = format("%s-%s", local.basename, "rule-access-iks")
#   enforcement_mode = "report"
#   contexts {
#     attributes {
#       name  = "networkZoneId"
#       value = ibm_cbr_zone.zone_vpc.id
#     }
#   }
#   resources {
#     attributes {
#       name  = "accountId"
#       value = data.ibm_iam_account_settings.account_settings.account_id
#     }
#     attributes {
#       name  = "serviceName"
#       value = "cloud-object-storage"
#     }
#     attributes {
#       name     = "serviceInstance"
#       operator = "stringEquals"
#       value    = ibm_resource_instance.cos_openshift_registry[0].guid
#     }
#   }
# }


resource "ibm_cbr_rule" "cbr_rule_cos" {
  description      = format("%s-%s", local.basename, "rule-cos")
  enforcement_mode = "report"
  contexts {
    attributes {
      name  = "networkZoneId"
      value = ibm_cbr_zone.zone_vpc.id
    }
  }
  resources {
    attributes {
      name  = "accountId"
      value = data.ibm_iam_account_settings.account_settings.account_id
    }
    attributes {
      name  = "serviceName"
      value = "cloud-object-storage"
    }
    attributes {
      name     = "serviceInstance"
      operator = "stringEquals"
      value    = ibm_resource_instance.cos_openshift_registry[0].guid
    }
  }
}

resource "ibm_cbr_rule" "cbr_rule" {
  description      = format("%s-%s", local.basename, "rule")
  enforcement_mode = "enabled"
  operations {
    api_types {
      api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:data-plane"
    }
  }
  contexts {
    attributes {
      name  = "networkZoneId"
      value = ibm_cbr_zone.cbr_zone_pgw.id
    }
    # attributes {
    #   name  = "endpointType"
    #   value = "private"
    # }
  }
  contexts {
    attributes {
      name  = "networkZoneId"
      value = ibm_cbr_zone.zone_home.id
    }
  }
  resources {
    attributes {
      name  = "accountId"
      value = data.ibm_iam_account_settings.account_settings.account_id
    }
    attributes {
      name  = "serviceName"
      value = "databases-for-mongodb"
    }
    attributes {
      name     = "serviceInstance"
      operator = "stringEquals"
      value    = ibm_database.icd_mongo.guid
    }
  }
}