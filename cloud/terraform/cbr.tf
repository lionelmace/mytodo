resource "ibm_cbr_zone" "cbr_zone" {
  name = format("%s-%s", var.prefix, "zone")
  addresses {
    type = "vpc"
    value = ibm_is_vpc.vpc.id
  }
}

resource "ibm_cbr_rule" "cbr_rule" {
  contexts {
        attributes {
            name = "networkZoneId"
            value = "559052eb8f43302824e7ae490c0281eb, bf823d4f45b64ceaa4671bee0479346e"
        }
    #     attributes {
    #            name = "endpointType"
    #            value = "private"
    # }
  }
  description = format("%s-%s", var.prefix, "rule")
  enforcement_mode = "enabled"
  resources {
        attributes {
            name = "serviceName"
            value = "databases-for-mongodb"
        }
        attributes {
          name = "serviceInstance"
          operator = "stringEquals"
          value = ibm_database.icd_mongo.id
        }
  }
}