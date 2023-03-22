resource "ibm_cbr_zone" "cbr_zone" {
  name       = format("%s-%s", var.prefix, "zone")
  account_id = var.account_id
  addresses {
    type  = "vpc"
    value = ibm_is_vpc.vpc.crn
  }
}

resource "ibm_cbr_zone" "cbr_zone_home" {
  name       = format("%s-%s", var.prefix, "home")
  account_id = var.account_id
  addresses {
    type  = "ipAddress"
    value = "92.151.223.28"
  }
}

# Zone with the VPC Public Gateways
resource "ibm_cbr_zone" "cbr_zone_pgw" {
  name       = format("%s-%s", var.prefix, "pgws")
  account_id = var.account_id
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

resource "ibm_cbr_rule" "cbr_rule" {
  description      = format("%s-%s", var.prefix, "rule")
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
      value = ibm_cbr_zone.cbr_zone_home.id
    }
  }
  resources {
    attributes {
      name  = "accountId"
      value = var.account_id
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