# Cloud Native Application

This Cloud Native Web App built with a common stack (Kubernetes, Mongo, Express, Angular and Node.js) is ready to be deployed on a container platform on IBM Cloud .

![Todo](./images/screenshot.png)

In order to use the cloud services required to run this app, you can provision the the underlying Cloud Native infrastructure thanks to Terraform by using this [repo](https://github.com/lionelmace/ibmcloud-native-architecture).

## Deploy images with Podman to ICR (IBM Container Registry)

1. Login to ICR

    ```sh
    ibmcloud cr login --client podman
    ```

1. Build docker image with the architecture platform for ROKS (x86_64)

    ```sh
    podman build --platform linux/amd64 . -t de.icr.io/mace2/mytodo:rh10
    ```

1. Push the image to the ICR

    ```sh
    podman push de.icr.io/mace2/mytodo:rh10
    ```

## Additional Resources

* To provision via Terraform the underlying infrastructure to run this app, follow this [tutorial](./README-terraform.md)

* To deploy this app in an automated way using IBM Cloud DevOps Toolchain, follow this [tutorial](./README-toolchain.md)

* To deploy this app step by step on top of an IKS (IBM Cloud Kubernetes Service) cluster, follow this [tutorial](https://lionelmace.github.io/iks-lab)