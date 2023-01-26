
## SCC Collector
##############################################################################

resource "ibm_scc_posture_collector" "scc_collector" {
  description = "sample collector"
  is_public   = true
  managed_by  = "ibm"
  name        = "${var.prefix}-collector"
  #   passphrase  = "secret"
}

## SCC Credentials
##############################################################################

resource "ibm_scc_posture_credential" "scc_credential" {
  description = "Credential used by SCC collector for connecting to the resources."
  display_fields {
    ibm_api_key = var.ibmcloud_api_key
  }
  enabled = true
  name    = "${var.prefix}-credentials"
  purpose = "discovery_fact_collection_remediation"
  type    = "ibm_cloud"
}

## SCC Scope
##############################################################################

resource "ibm_scc_posture_scope" "scc_scope" {
  collector_ids = [ibm_scc_posture_collector.scc_collector.id]
  #   collector_ids   = ["${ibm_scc_posture_collector.scc_collector.id}"]
  credential_id   = ibm_scc_posture_credential.scc_credential.id
  credential_type = "ibm"
  description     = "IBMSchema"
  #   interval = 10
  #   is_discovery_scheduled = true
  name = "${var.prefix}-scope"
}

## SCC Scan
##############################################################################

resource "ibm_scc_posture_scan_initiate_validation" "scc_scan" {
  scope_id = ibm_scc_posture_scope.scc_scope.id
  # IBM Cloud Security Best Practices - Profile Id
  # https://cloud.ibm.com/security-compliance/profiles
  profile_id = "19"
  name       = "${var.prefix}-scope"
  #   group_profile_id = "group_profile_id"
  #   description = "description"
  #   frequency = 1
  #   no_of_occurrences = 1
}