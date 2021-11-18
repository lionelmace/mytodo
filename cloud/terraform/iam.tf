resource "ibm_iam_access_group" "accgrp" {
  name = "${var.prefix}-ag"
}

resource "ibm_iam_access_group_policy" "policy-cos" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Viewer"]

  resources {
    service           = "cloud-object-storage"
    resource_group_id = ibm_resource_group.resource_group.id
  }
}

# Create a policy to all Kubernetes instances within the Resource Group
resource "ibm_iam_access_group_policy" "policy-k8s" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Viewer"]

  resources {
    service           = "containers-kubernetes"
    resource_group_id = ibm_resource_group.resource_group.id
  }
}

# Authorization policy between Mongo and Key Protect
# Require to encrypt Mongo DB with Key in Key Protect
resource "ibm_iam_authorization_policy" "policy" {
  source_service_name = "databases-for-mongodb"
  target_service_name = "kms"
  roles               = ["Reader"]
}
