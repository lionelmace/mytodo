
variable "environment_name" {
  default = "terraform-env"
}

variable "cluster_datacenter" {
  description = "CLI: ibmcloud ks locations"
  default     = "fra02"
}

variable "cluster_machine_type" {
  description = "ibmcloud ks machine-types <datacenter>"
  default     = "u2c.2x4"
}

variable "cluster_worker_num" {
  default = "1"
}

variable "cluster_public_vlan_id" {
  description = "CLI: ibmcloud ks vlans <datacenter>"
  default     = "1898"
}

variable "cluster_private_vlan_id" {
  description = "CLI: ibmcloud ks vlans <datacenter>"
  default     = "1817"
}

variable "cluster_hardware" {
  description = "Shared, Dedicated or Bare Metal"
  default     = "shared"
}

variable "cluster_kube_version" {
  description = "Retrieve the Kubernetes version using cli: ibmcloud ks kube-versions"
  default     = "1.12.2"
}

# a cluster
resource "ibm_container_cluster" "cluster" {
  name              = "${var.environment_name}-cluster"
  datacenter        = "${var.cluster_datacenter}"
  machine_type      = "${var.cluster_machine_type}"
  # worker_num        = "${var.cluster_worker_num}"
  public_vlan_id    = "${var.cluster_public_vlan_id}"
  private_vlan_id   = "${var.cluster_private_vlan_id}"
  hardware          = "${var.cluster_hardware}"
  kube_version      = "${var.cluster_kube_version}"
  region            = "${var.ibmcloud_location}"
  # resource_group_id = "${data.ibm_resource_group.group.id}"
  # tags              = ["terraform", "dev"]
}

# resource "ibm_container_worker_pool" "cluster_workerpool" {
#   worker_pool_name  = "${var.environment_name}-pool"
#   machine_type      = "${var.cluster_machine_type}"
#   cluster           = "${ibm_container_cluster.cluster.id}"
#   size_per_zone     = "${var.cluster_worker_num}"
#   hardware          = "${var.cluster_hardware}"
#   # resource_group_id = "${ibm_resource_group.group.id}"  
# }