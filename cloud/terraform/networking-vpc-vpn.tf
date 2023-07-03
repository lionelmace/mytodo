# Authorization policy between VPN and Secrets Manager
resource "ibm_iam_authorization_policy" "vpn-sm" {
  source_service_name         = "is"
  source_resource_type        = "vpn-server"
  target_service_name         = "secrets-manager"
  #LMA target_resource_instance_id = ibm_resource_instance.secrets-manager.guid
  target_resource_instance_id = local.secrets_manager_guid
  roles                       = ["SecretsReader"]
}