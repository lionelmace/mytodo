# data "ibm_resource_group" "group" {
#   name = "default"
# }

# resource "ibm_resource_instance" "icd_postgres" {
#   name              = "icd-postgres-created-with-terraform"
#   location          = "${var.ibmcloud_location}"
#   service           = "databases-for-postgresql"
#   plan              = "standard"
#   # If not provided it takes the default resource group.
#   # resource_group_id = "${data.ibm_resource_group.group.id}"


#   parameters = {
#     version = "9.6"
#     # Total amount of memory to be shared between the DB members
#     # Postgres has 2 members by default.
#     "members_memory_allocation_mb" = "8192"
#   }
# }