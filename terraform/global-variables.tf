variable "ibmcloud_location" {
  default = "eu-de"
}

data "ibm_resource_group" "group" {
  name = "demo"
}