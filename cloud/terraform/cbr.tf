resource "ibm_cbr_zone" "cbr_zone" {
  name       = format("%s-%s", var.prefix, "zone")
  account_id = "0b5a00334eaf9eb9339d2ab48f7326b4"
  addresses {
    type  = "vpc"
    value = ibm_is_vpc.vpc.crn
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
      value = ibm_cbr_zone.cbr_zone.id
    }
    #     attributes {
    #            name = "endpointType"
    #            value = "private"
    # }
  }
  resources {
    attributes {
      name  = "accountId"
      value = "0b5a00334eaf9eb9339d2ab48f7326b4"
    }
    attributes {
      name  = "serviceName"
      value = "databases-for-mongodb"
    }
    attributes {
      name     = "serviceInstance"
      operator = "stringEquals"
      value    = ibm_database.icd_mongo.id
    }
  }
}