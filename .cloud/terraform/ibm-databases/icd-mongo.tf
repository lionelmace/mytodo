resource "ibm_database" "icd_mongo" {
  name     = "icd-mongo-created-with-terraform"
  location = var.ibmcloud_region
  service  = "databases-for-mongodb"
  plan     = "standard"
  version  = "4.0"
  # If not provided it takes the default resource group.
  # resource_group_id = "${data.ibm_resource_group.group.id}"

  # Total amount of memory to be shared between the DB members
  # Postgres has 2 members by default.
  # Memory requires a minimum of 2048 MB
  members_memory_allocation_mb = 2048
  # Disk requires a minimum of 20480 MB
  members_disk_allocation_mb = 20480

  timeouts {
    # Default timeout is 10mins
    create = "15m"
    delete = "3m"
  }
}