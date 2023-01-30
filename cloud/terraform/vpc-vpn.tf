# Authorization policy between VPN and Secrets Manager
resource "ibm_iam_authorization_policy" "vpn-sm" {
  source_service_name  = "is"
  source_resource_type = "vpn-server"
  # source_resource_instance_id = 
  target_service_name         = "secrets-manager"
  target_resource_instance_id = ibm_resource_instance.secrets-manager.guid
  roles                       = ["SecretsReader"]
}