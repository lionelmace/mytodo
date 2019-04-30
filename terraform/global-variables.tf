variable "ibmcloud_region" {
  default = "eu-de"
}

variable "ibmcloud_az1" {
  default = "fra02"
}

variable "ibmcloud_az2" {
  default = "fra04"
}

variable "ibmcloud_az3" {
  default = "fra05"
}

data "ibm_resource_group" "group" {
  name = "demo"
}