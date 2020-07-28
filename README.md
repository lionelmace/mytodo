# Introduction

This web app built with a CLEAN stack (CLoudant NoSQL DB, Express, Angular and Node.js) is ready to be deployed on ICP (IBM Cloud Platform).

![Todo](./images/screenshot.png)


# How to deploy this app in Kubernetes?

1. If you don't already have a Kubernetes cluster, create one for **Free** from IBM Cloud Catalog by selecting the [Kubernetes Service](https://cloud.ibm.com/kubernetes/catalog/create).

    Give it a **Name** and select a **Resource Group**.
    > 20 min provisioning time

    ![Cluster](./images/iks-free-cluster.jpg)

1. [Optional] If you want to securely store your API Key used in the Continuous Delivery later, provision a service [Key Protect](https://cloud.ibm.com/catalog/services/key-protect).

    Make sure to select the same **Region** as your cluster location, enter a **Service Name**, select a **Resource Group** and a **Network Policy**.
    > 2 min provisioning time

    ![Key Protect](./images/key-protect.jpg)

1. To automate the deployment of this app into your Kubernetes cluster, click the button **Deploy app with DevOps toolchain**.

    <a href="https://cloud.ibm.com/devops/setup/deploy?repository=https://github.com/lionelmace/mytodo&branch=master" target=”_blank”>![](./images/toolchain0-button.png)</a>


1. Enter a toolchain **Name**, select the **Region** and a **Resource Group** where your cluster was created.

    ![Toolchain](./images/toolchain1-create.jpg)

1. Keep the default setting in the tab **Git Repos and Issue Tracking**.

    ![Toolchain](./images/toolchain2-git.jpg)

1. In the tab **Delivery Pipeline**, create a new API Key.

    ![Toolchain](./images/toolchain3-newkey.jpg)

1. A panel will open, check the option **Save this key in a secrets store for resuse** if you have created an instance of the service Key Protect.

    ![Toolchain](./images/toolchain4-secretkey.jpg)

    > Keep this option unchecked if you don't have a service instance of Key Protect.

1. The toolchain will automatically try to fill out the remaining information. Control the Resource Group, the region and the cluster name, then, click **Create**. 

    ![Toolchain](./images/toolchain5-final.jpg)

1. The toolchain will automatically try to fill out the remaining information. Control the Resource Group, the region and the cluster name, then, click **Create**. 

    ![Toolchain](./images/toolchain5-final.jpg)

1. The toolchain is being created. That includes a Github repo to clone the source code of the app. 

    ![Toolchain](./images/toolchain6-overview.jpg)

1. Click **Delivery Pipeline** in the Overview. You will the pipeline in progress.

    > 6 min deployment time 
    ![Toolchain](./images/toolchain7-pipeline.jpg)

1. Click the link **View logs and history** in the last stage **DEPLOY**. Scroll down to the bottom. You will find the link to your application.

    ![Toolchain](./images/toolchain8-applink.jpg)

Congratulations! Your app is up and running in the cluter.


# Step by step Deployment

Those two tutorials will show you in details how to deploy this step by step:

* With IKS (IBM Cloud Kubernetes Service), follow this [tutorial](https://lionelmace.github.io/iks-lab)

* With ICF (IBM Cloud Foundry), follow this [tutorial](https://github.com/lionelmace/bluemix-labs/tree/master/labs/Lab%20CloudFoundry%20-%20Deploy%20TODO%20web%20application)