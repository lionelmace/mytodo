This sample application is built with a CLEAN stack (CLoudant NoSQL database, Express, Angular and Node.js) and is ready to be deployed on IBM Bluemix.

![Todo](./screenshot.png)

To deploy this application into Cloud Foundry on IBM Bluemix, follow this [tutorial](https://github.com/lionelmace/bluemix-labs/tree/master/labs/Lab%20CloudFoundry%20-%20Deploy%20TODO%20web%20application)

To deploy this application into Kubernetes on IBM Bluemix, follow the steps below:

```bx service create cloudantNoSQLDB Lite mycloudantinstance```

```bx cs cluster-service-bind <cluster_id> <kube_namespace> <service_instance_name>```

```docker build -t registry.ng.bluemix.net/<namespace>/todo:secrets .```

```docker push registry.ng.bluemix.net/<namespace>/todo:secrets```

```kubectl create -f kubernetes-deployment.yml```

```bx cs workers <cluster-name>``` to get the worker node ip

```kubectl get services``` to get the port

The applicaiton is running on http://<ip-address>:<port>

```kubectl scale --replicas=3 -f kubernetes-deployment.yml```

```kubectl delete -f kubernetes-deployment.yml```
