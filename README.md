# Introduction

This web app built with a CLEAN stack (CLoudant NoSQL DB, Express, Angular and Node.js) is ready to be deployed on ICP IBM Cloud Platform.

![Todo](./images/screenshot.png)


# How to deploy this app?

1. Create a free Kubernetes cluster from the catalog by clicking [Kubernetes Service](https://cloud.ibm.com/kubernetes/catalog/create)

    ![Todo](./images/iks-free-cluster.jpg)

1. Deploy this app in a few clicks on an existing Kubernetes cluster using DevOps:

<a href="https://cloud.ibm.com/devops/setup/deploy?repository=https://github.com/lionelmace/mytodo&branch=master">![](./images/createtoolchain.png)</a>

> The overal deployment takes 15-20 mins.

![Delivery Pipeline](./images/deliverypipeline.png)


# Step by step deployment
Deploy this application step by step:

* With IKS (IBM Cloud Kubernetes Service), follow this [tutorial](https://lionelmace.github.io/iks-lab)

* With ICF (IBM Cloud Foundry), follow this [tutorial](https://github.com/lionelmace/bluemix-labs/tree/master/labs/Lab%20CloudFoundry%20-%20Deploy%20TODO%20web%20application)