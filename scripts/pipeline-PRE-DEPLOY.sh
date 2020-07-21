#!/bin/bash
# uncomment to debug the script
#set -x
# copy the script below into your app code repo (e.g. ./scripts/check_predeploy.sh) and 'source' it from your pipeline job
#    source ./scripts/check_predeploy.sh
# alternatively, you can source it from online script:
#    source <(curl -sSL "https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/check_predeploy.sh")
# ------------------
# source: https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/check_predeploy.sh
# Input env variables (can be received via a pipeline environment properties.file.
echo "CHART_PATH=${CHART_PATH}"
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "IMAGE_TAG=${IMAGE_TAG}"
echo "PIPELINE_STAGE_INPUT_REV=${PIPELINE_STAGE_INPUT_REV}"
echo "REGISTRY_URL=${REGISTRY_URL}"
echo "REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE}"
      #View build properties
# cat build.properties
# also run 'env' command to find all available env variables
# or learn more about the available environment variables at:
# https://console.bluemix.net/docs/services/ContinuousDelivery/pipeline_deploy_var.html#deliverypipeline_environment

# Input env variables from pipeline job
echo "PIPELINE_KUBERNETES_CLUSTER_NAME=${PIPELINE_KUBERNETES_CLUSTER_NAME}"
echo "CLUSTER_NAMESPACE=${CLUSTER_NAMESPACE}"

#Check cluster availability
echo "=========================================================="
echo "CHECKING CLUSTER readiness and namespace existence"
if [ -z "${KUBERNETES_MASTER_ADDRESS}" ]; then
  CLUSTER_ID=${PIPELINE_KUBERNETES_CLUSTER_ID:-${PIPELINE_KUBERNETES_CLUSTER_NAME}} # use cluster id instead of cluster name to handle case where there are multiple clusters with same name
  IP_ADDR=$( ibmcloud ks workers --cluster ${CLUSTER_ID} | grep normal | head -n 1 | awk '{ print $2 }' )
  if [ -z "${IP_ADDR}" ]; then
    echo -e "${PIPELINE_KUBERNETES_CLUSTER_NAME} not created or workers not ready"
    exit 1
  fi
fi
echo "Configuring cluster namespace"
if kubectl get namespace ${CLUSTER_NAMESPACE}; then
  echo -e "Namespace ${CLUSTER_NAMESPACE} found."
else
  kubectl create namespace ${CLUSTER_NAMESPACE}
  echo -e "Namespace ${CLUSTER_NAMESPACE} created."
fi

# Grant access to private image registry from namespace $CLUSTER_NAMESPACE
# reference https://cloud.ibm.com/docs/containers?topic=containers-images#other_registry_accounts
echo "=========================================================="
echo -e "CONFIGURING ACCESS to private image registry from namespace ${CLUSTER_NAMESPACE}"
IMAGE_PULL_SECRET_NAME="ibmcloud-toolchain-${PIPELINE_TOOLCHAIN_ID}-${REGISTRY_URL}"

echo -e "Checking for presence of ${IMAGE_PULL_SECRET_NAME} imagePullSecret for this toolchain"
if ! kubectl get secret ${IMAGE_PULL_SECRET_NAME} --namespace ${CLUSTER_NAMESPACE}; then
  echo -e "${IMAGE_PULL_SECRET_NAME} not found in ${CLUSTER_NAMESPACE}, creating it"
  # for Container Registry, docker username is 'token' and email does not matter
  if [ -z "${PIPELINE_BLUEMIX_API_KEY}" ]; then PIPELINE_BLUEMIX_API_KEY=${IBM_CLOUD_API_KEY}; fi #when used outside build-in kube job
  kubectl --namespace ${CLUSTER_NAMESPACE} create secret docker-registry ${IMAGE_PULL_SECRET_NAME} --docker-server=${REGISTRY_URL} --docker-password=${PIPELINE_BLUEMIX_API_KEY} --docker-username=iamapikey --docker-email=a@b.com
else
  echo -e "Namespace ${CLUSTER_NAMESPACE} already has an imagePullSecret for this toolchain."
fi
if [ -z "${KUBERNETES_SERVICE_ACCOUNT_NAME}" ]; then KUBERNETES_SERVICE_ACCOUNT_NAME="default" ; fi
SERVICE_ACCOUNT=$(kubectl get serviceaccount ${KUBERNETES_SERVICE_ACCOUNT_NAME}  -o json --namespace ${CLUSTER_NAMESPACE} )
if ! echo ${SERVICE_ACCOUNT} | jq -e '. | has("imagePullSecrets")' > /dev/null ; then
  kubectl patch --namespace ${CLUSTER_NAMESPACE} serviceaccount/${KUBERNETES_SERVICE_ACCOUNT_NAME} -p '{"imagePullSecrets":[{"name":"'"${IMAGE_PULL_SECRET_NAME}"'"}]}'
else
  if echo ${SERVICE_ACCOUNT} | jq -e '.imagePullSecrets[] | select(.name=="'"${IMAGE_PULL_SECRET_NAME}"'")' > /dev/null ; then 
    echo -e "Pull secret already found in ${KUBERNETES_SERVICE_ACCOUNT_NAME} serviceAccount"
  else
    echo "Inserting toolchain pull secret into ${KUBERNETES_SERVICE_ACCOUNT_NAME} serviceAccount"
    kubectl patch --namespace ${CLUSTER_NAMESPACE} serviceaccount/${KUBERNETES_SERVICE_ACCOUNT_NAME} --type='json' -p='[{"op":"add","path":"/imagePullSecrets/-","value":{"name": "'"${IMAGE_PULL_SECRET_NAME}"'"}}]'
  fi
fi
echo "${KUBERNETES_SERVICE_ACCOUNT_NAME} serviceAccount:"
kubectl get serviceaccount ${KUBERNETES_SERVICE_ACCOUNT_NAME} --namespace ${CLUSTER_NAMESPACE} -o yaml
echo -e "Namespace ${CLUSTER_NAMESPACE} authorizing with private image registry using patched ${KUBERNETES_SERVICE_ACCOUNT_NAME} serviceAccount"


echo "=========================================================="
echo "CONFIGURING TILLER enabled (Helm server-side component)"

echo -e "\n==## Installing Helm 2.12.2"
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.2-linux-amd64.tar.gz
tar -xzvf helm-v2.12.2-linux-amd64.tar.gz
mkdir $HOME/helm212
mv linux-amd64/helm $HOME/helm212/
export PATH=$HOME/helm212:$PATH
rm helm-v2.12.2-linux-amd64.tar.gz

kubectl apply -f kubernetes/tiller-rbac-config.yaml

helm init --upgrade --service-account tiller
kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system
helm version

echo "=========================================================="
echo -e "CHECKING HELM releases in this namespace: ${CLUSTER_NAMESPACE}"
helm list --namespace ${CLUSTER_NAMESPACE}