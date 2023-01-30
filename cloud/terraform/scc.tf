
## SCC Collector
##############################################################################

resource "ibm_scc_posture_collector" "scc_collector" {
  description = "sample collector"
  is_public   = true
  managed_by  = "ibm"
  name        = "${var.prefix}-collector"
}

## SCC Credentials
##############################################################################

resource "ibm_scc_posture_credential" "scc_credential" {
  description = "Credential used by collector for connecting to the resources."
  display_fields {
    ibm_api_key = var.ibmcloud_api_key
  }
  enabled = true
  name    = "${var.prefix}-credentials"
  purpose = "discovery_fact_collection" # "discovery_fact_collection_remediation"
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

data "ibm_scc_posture_profiles" "list_profiles" {
}

data "ibm_scc_posture_profile" "profile_security_bestpractices" {
  profile_id   = data.ibm_scc_posture_profiles.list_profiles.profiles[index(data.ibm_scc_posture_profiles.list_profiles.profiles.*.name, "IBM Cloud Security Best Practices v1.0.0")].id
  profile_type = "predefined"
}

resource "ibm_scc_posture_scan_initiate_validation" "scc_scan" {
  scope_id = ibm_scc_posture_scope.scc_scope.id
  # IBM Cloud Security Best Practices (profile_id=19)
  profile_id = data.ibm_scc_posture_profile.profile_security_bestpractices.profile_id
  name       = "${var.prefix}-scan"
  # For On-Demand scan, comment the frequency
  # Minimum scan frequency limit is 1 hour (= 3600 msec)
  frequency = 3600
  #   no_of_occurrences = 1
}