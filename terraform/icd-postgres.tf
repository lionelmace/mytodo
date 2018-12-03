data "ibm_resource_group" "group" {
  name = "default"
}

resource "ibm_resource_instance" "test_icd_postgres_creation" {
  name              = "icd-posgres-created-with-terraform"
  location          = "eu-de"
  # (Optional, string) The id of the resource group where the resource instance exists.
  # If not provided it takes the default resource group.
  # resource_group_id = "${data.ibm_resource_group.group.id}"
  service           = "databases-for-postgresql"
  plan              = "standard"
}