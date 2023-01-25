# Authorization policy between VPN and Secrets Manager
resource "ibm_iam_authorization_policy" "vpn-sm" {
  source_service_name  = "is"
  source_resource_type = "vpn-server"
  # source_resource_instance_id = 
  target_service_name         = "secrets-manager"
  target_resource_instance_id = ibm_resource_instance.secrets-manager.guid
  roles                       = ["SecretsReader"]
}


##############################################################################
## Secrets Manager
##############################################################################
resource "ibm_resource_instance" "secrets-manager" {
  name              = format("%s-%s", var.prefix, "secrets-manager")
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id
  tags              = var.tags
  service_endpoints = "private"
}

output "secrets-manager-crn" {
  description = "The CRN of the Secrets Manager instance"
  value       = ibm_resource_instance.secrets-manager.id
}

# resource "null_resource" "attach-secrets-manager-to-openshift" {

#   triggers = {
#     APIKEY             = var.ibmcloud_api_key
#     REGION             = var.region
#     CLUSTER_ID         = module.vpc_openshift_cluster.vpc_openshift_cluster_id
#     SECRETS_MANAGER_ID = ibm_resource_instance.secrets-manager.id
#   }

#   provisioner "local-exec" {
#     command = "./attach-secrets-manager.sh"
#     environment = {
#       APIKEY             = self.triggers.APIKEY
#       REGION             = self.triggers.REGION
#       CLUSTER_ID         = self.triggers.CLUSTER_ID
#       SECRETS_MANAGER_ID = self.triggers.SECRETS_MANAGER_ID
#     }
#   }

#   # provisioner "local-exec" {
#   #   when    = destroy
#   #   command = "./secrets-destroy.sh"
#   #   environment = {
#   #     APIKEY             = self.triggers.APIKEY
#   #     REGION             = self.triggers.REGION
#   #     SECRETS_MANAGER_ID = self.triggers.SECRETS_MANAGER_ID
#   #   }
#   # }

#   depends_on = [ ibm_iam_authorization_policy.roks-sm, ]
# }