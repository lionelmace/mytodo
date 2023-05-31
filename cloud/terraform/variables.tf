##############################################################################
# Account Variables
##############################################################################

variable "account_id" {
  description = "A unique identifier of the account"
  type        = string
}

variable "prefix" {
  description = "A unique identifier need to provision resources. Must begin with a letter"
  type        = string
}

variable "region" {
  description = "IBM Cloud region where all resources will be provisioned"
  default     = "eu-de"
}

variable "tags" {
  description = "List of Tags"
  type        = list(string)
  default     = ["tf", "mytodo"]
}