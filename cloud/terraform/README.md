# Deploy the Cloud Native Architecture via Terraform

All the Cloud Services will be provisioned through the use of Terraform.

Cloud Native Architecture is visible in this [diagram](https://raw.githubusercontent.com/lionelmace/mytodo/master/images/ibmcloud-mytodo-tf.svg)

List of Cloud Services:

* VPC with 3 subnets, 3 public gateways
* Kubernetes cluster
* OpenShift cluster
* Mongo Standard DBaaS with Virtual Private Endpoint
* Log Analysis based on Mezmo
* Cloud Monitoring based on Sysdig
* COS with a bucket
* Key Protect to encrypt the COS bucket, the database
* Context-Based Restrictions (CBR) Zone and Rule
* Secrets Manager to store the cluster certificate

> Both Log Analysis and Monitoring instances will be attached to the clusters.

## Resources

* IBM Cloud Terraform Provider is available on [HashiCorp Terraform Registry](https://registry.terraform.io/providers/IBM-Cloud/ibm).
* To use those Terraform, follow this [tutorial](https://lionelmace.github.io/iks-lab/#/05-advanced/appendix-terraform)
