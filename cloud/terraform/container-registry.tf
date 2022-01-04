resource "ibm_cr_namespace" "cr_namespace" {
  name = "${var.prefix}-cr-ns"
  resource_group_id = ibm_resource_group.resource_group.id
  tags = var.tags
}