
## Collector
##############################################################################

resource "ibm_scc_posture_collector" "scc_collector" {
  description = "sample collector"
  is_public   = true
  managed_by  = "ibm"
  name        = "${var.prefix}-collector"
  #   passphrase  = "secret"
}

## Credentials
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

## Scope
##############################################################################

resource "ibm_scc_posture_scope" "scopes" {
  collector_ids = [ibm_scc_posture_collector.scc_collector.id]
  #   collector_ids   = ["${ibm_scc_posture_collector.scc_collector.id}"]
  credential_id   = ibm_scc_posture_credential.scc_credential.id
  credential_type = "ibm"
  description     = "IBMSchema"
  #   interval = 10
  #   is_discovery_scheduled = true
  name = "IBMSchema-new-048-test"
}

## Scan
##############################################################################

resource "ibm_scc_posture_scan_initiate_validation" "scc_scan" {
  scope_id = ibm_scc_posture_scope.scopes.id
  # IBM Cloud Security Best Practices - Profile Id
  # https://cloud.ibm.com/security-compliance/profiles/cff60115-4ea0-4a67-8ef2-49f319403969
  profile_id = "394"
  name       = "${var.prefix}-scope"
  #   group_profile_id = "group_profile_id"
  #   description = "description"
  #   frequency = 1
  #   no_of_occurrences = 1
}