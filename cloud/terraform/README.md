# Deploy the Cloud Native Architecture via Terraform

All the cloud services shown in the architecture below can be provisioned through the use of Terraform.

![Architecture](../../images/ibmcloud-mytodo-tf.svg)

All those service instances will be created by terraform:

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

> Both LogDNA and Sysdig instance will be attached to both clusters.

## Resources

* IBM Cloud Terraform Provider is available on [HashiCorp Terraform Registry](https://registry.terraform.io/providers/IBM-Cloud/ibm).
* To use those Terraform, follow this [tutorial](https://lionelmace.github.io/iks-lab/#/05-advanced/appendix-terraform)
