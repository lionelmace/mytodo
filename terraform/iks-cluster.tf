
variable "environment_name" {
  default = "terraform-env"
}

# The datacenter of the worker nodes
variable "cluster_datacenter" {
  description = "CLI: ibmcloud ks locations"
  default     = "fra02, fra04, fra05"
  
}

variable "cluster_machine_type" {
  description = "CLI: ibmcloud ks machine-types <datacenter>"
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

# The desired Kubernetes version of the created cluster.
# If present, at least major.minor must be specified.
variable "cluster_kube_version" {
  description = "CLI: ibmcloud ks kube-versions"
  default     = "1.13.4"
}

# a cluster
resource "ibm_container_cluster" "cluster" {
  name              = "${var.environment_name}-cluster"
  datacenter        = "${var.cluster_datacenter}"
  machine_type      = "${var.cluster_machine_type}"
  worker_num        = "${var.cluster_worker_num}"
  public_vlan_id    = "${var.cluster_public_vlan_id}"
  private_vlan_id   = "${var.cluster_private_vlan_id}"
  hardware          = "${var.cluster_hardware}"
  kube_version      = "${var.cluster_kube_version}"
  # The region where the cluster is provisioned
  region            = "${var.ibmcloud_location}"
  resource_group_id = "${data.ibm_resource_group.group.id}"
  tags              = ["terraform", "dev"]
}

resource "ibm_container_worker_pool" "cluster_worker_pool" {
  cluster           = "${var.environment_name}-cluster"
  worker_pool_name  = "${var.environment_name}-pool"
  machine_type      = "${var.cluster_machine_type}"
  size_per_zone     = "${var.cluster_worker_num}"
  hardware          = "${var.cluster_hardware}"
  region            = "${var.ibmcloud_location}"
}