resource "ibm_resource_instance" "icd_postgres" {
  name              = "icd-postgres-created-with-terraform"
  location          = "${var.ibmcloud_region}"
  service           = "databases-for-postgresql"
  plan              = "standard"
  # If not provided it takes the default resource group.
  # resource_group_id = "${data.ibm_resource_group.group.id}"

  parameters = {
    version = "10"
    # Total amount of memory to be shared between the DB members
    # Postgres has 2 members by default.
    # Memory requires a minimum of 2048 MB
    "members_memory_allocation_mb" = "2048"
    # Disk requires a minimum of 10240 MB
    "members_disk_allocation_mb" = "10240"
  }

  timeouts {
    # Default timeout is 10mins
    create = "15m"
    delete = "3m"
  }
}