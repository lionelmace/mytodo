# Deploy an IBM Cloud Native Architecture via Terraform

This IBM Cloud Native Architecture is visible in this [diagram](https://raw.githubusercontent.com/lionelmace/mytodo/master/images/ibmcloud-mytodo-tf.png)

The Terraform scripts will provision all those Cloud Services:

* a VPC with 3 subnets, 3 public gateways
* a cluster Kuberneter
* a cluster OpenShift
* a database Mongo Standard with VPE (Virtual Private Endpoint)
* a Log Analysis based on Mezmo
* a Cloud Monitoring based on Sysdig
* a Object Storage with a bucket
* a Key Protect to encrypt the COS bucket and the Mongo database
* Some CBR (Context-Based Restrictions) Zones and Rules
* A Secrets Manager (Hashicorp Vault aaS) to store the cluster certificate

Both Log Analysis and Monitoring instances will be attached to the clusters.

## Resources

* IBM Cloud Terraform Provider is available at [HashiCorp Terraform Registry](https://registry.terraform.io/providers/IBM-Cloud/ibm).
* To use those Terraform, follow this [tutorial](https://lionelmace.github.io/iks-lab/#/05-advanced/appendix-terraform)
