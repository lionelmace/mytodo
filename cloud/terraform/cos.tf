variable "platform_activity_tracker" {
  description = "Name of Platform Activity Tracker"
  type        = string
  default     = "platform-activities"
}

data "ibm_resource_instance" "activity_tracker" {
  name = var.platform_activity_tracker
}

##############################################################################
# COS Service for OpenShift Internal Registry
##############################################################################

resource "ibm_resource_instance" "cos" {
  name              = format("%s-%s", var.prefix, "openshift-registry")
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = var.cos_region
  resource_group_id = ibm_resource_group.resource_group.id
  tags              = var.tags

  parameters = {
    service-endpoints = "private"
  }
}

## COS Bucket
##############################################################################

resource "ibm_cos_bucket" "standard-bucket" {
  bucket_name          = "a-smart-bucket-at-eu-de"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = "eu-de"
  storage_class        = "smart"
  activity_tracking {
    read_data_events     = true
    write_data_events    = true
    activity_tracker_crn = data.ibm_resource_instance.activity_tracker.id
  }
  metrics_monitoring {
    usage_metrics_enabled   = true
    request_metrics_enabled = true
    metrics_monitoring_crn  = module.monitoring_instance.id
  }
  # allowed_ip = ["223.196.168.27", "223.196.161.38", "192.168.0.1"]
}


## IAM
##############################################################################

resource "ibm_iam_access_group_policy" "policy-cos" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Viewer"]

  resources {
    service           = "cloud-object-storage"
    resource_group_id = ibm_resource_group.resource_group.id
  }
}
