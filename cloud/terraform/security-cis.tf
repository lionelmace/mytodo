data "ibm_cis" "cis_instance" {
  name = "cis-lionelmace"
}

data "ibm_cis_domain" "cis_instance_domain" {
  domain = "example.com"
  cis_id = ibm_cis.cis_instance.id
}

# output "cis_domain_name" {
#   description = "The CIS Domain name"
#   value       = ibm_cis.cis_instance.
# }
