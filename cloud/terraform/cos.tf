
##############################################################################
# COS Service for OpenShift Internal Registry
##############################################################################

resource "ibm_resource_instance" "cos" {
  name              = "${var.prefix}-openshift-registry"
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = var.cos_region
  resource_group_id = ibm_resource_group.resource_group.id
  tags              = var.tags

  parameters = {
    service-endpoints = "private"
  }
}