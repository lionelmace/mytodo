#!/bin/bash
# uncomment to debug the script
#set -x
# copy the script below into your app code repo (e.g. ./scripts/deploy_helm.sh) and 'source' it from your pipeline job
#    source ./scripts/deploy_helm.sh
# alternatively, you can source it from online script:
#    source <(curl -sSL "https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/deploy_helm.sh")
# ------------------
# source: https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/deploy_helm.sh
# Input env variables (can be received via a pipeline environment properties.file.

CHART_PATH="chart/mytodos"
echo "CHART_PATH=${CHART_PATH}"
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "IMAGE_TAG=${IMAGE_TAG}"
echo "BUILD_NUMBER=${BUILD_NUMBER}"
echo "REGISTRY_URL=${REGISTRY_URL}"
echo "REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE}"
echo "PIPELINE_STAGE_INPUT_REV=${PIPELINE_STAGE_INPUT_REV}"

#View build properties
# cat build.properties
# also run 'env' command to find all available env variables
# or learn more about the available environment variables at:
# https://console.bluemix.net/docs/services/ContinuousDelivery/pipeline_deploy_var.html#deliverypipeline_environment

# Input env variables from pipeline job
echo "PIPELINE_KUBERNETES_CLUSTER_NAME=${PIPELINE_KUBERNETES_CLUSTER_NAME}"
echo "CLUSTER_NAMESPACE=${CLUSTER_NAMESPACE}"

# Infer CHART_NAME from path to chart (last segment per construction for valid charts)
CHART_NAME=$(basename $CHART_PATH)
echo "CHART_NAME=${CHART_NAME}"


# Check cluster availability
echo -e "\\n=========================================================="
echo "CHECKING CLUSTER readiness and namespace existence"
IP_ADDR=$(ibmcloud ks workers --cluster ${PIPELINE_KUBERNETES_CLUSTER_NAME} | grep normal | awk '{ print $2 }')
if [ -z "${IP_ADDR}" ]; then
  echo -e "${PIPELINE_KUBERNETES_CLUSTER_NAME} not created or workers not ready"
  exit 1
fi
echo "Configuring cluster namespace"
kubectl get ns
if kubectl get namespace ${CLUSTER_NAMESPACE}; then
  echo -e "Namespace ${CLUSTER_NAMESPACE} found."
else
  kubectl create namespace ${CLUSTER_NAMESPACE}
  echo -e "Namespace ${CLUSTER_NAMESPACE} created."
fi


# Grant access to private image registry from namespace $CLUSTER_NAMESPACE
# reference https://console.bluemix.net/docs/containers/cs_cluster.html#bx_registry_other
echo -e "\\n=========================================================="
echo -e "CONFIGURING ACCESS to private image registry from namespace ${CLUSTER_NAMESPACE}"
IMAGE_PULL_SECRET_NAME="ibmcloud-toolchain-${PIPELINE_TOOLCHAIN_ID}-${REGISTRY_URL}"
echo -e "Checking for presence of ${IMAGE_PULL_SECRET_NAME} imagePullSecret for this toolchain"
if ! kubectl get secret ${IMAGE_PULL_SECRET_NAME} --namespace ${CLUSTER_NAMESPACE}; then
  echo -e "${IMAGE_PULL_SECRET_NAME} not found in ${CLUSTER_NAMESPACE}, creating it"
  # for Container Registry, docker username is 'token' and email does not matter
  kubectl --namespace ${CLUSTER_NAMESPACE} create secret docker-registry ${IMAGE_PULL_SECRET_NAME} --docker-server=${REGISTRY_URL} --docker-password=${PIPELINE_BLUEMIX_API_KEY} --docker-username=iamapikey --docker-email=a@b.com
else
  echo -e "Namespace ${CLUSTER_NAMESPACE} already has an imagePullSecret for this toolchain."
fi
echo "Checking ability to pass pull secret via Helm chart"
CHART_PULL_SECRET=$( grep 'pullSecret' ./chart/${CHART_NAME}/values.yaml || : )
if [ -z "$CHART_PULL_SECRET" ]; then
  echo "WARNING: Chart is not expecting an explicit private registry imagePullSecret. Will patch the cluster default serviceAccount to pass it implicitly for now."
  echo "Going forward, you should edit the chart to add in:"
  echo -e "[./chart/${CHART_NAME}/templates/deployment.yaml] (under kind:Deployment)"
  echo "    ..."
  echo "    spec:"
  echo "      imagePullSecrets:               #<<<<<<<<<<<<<<<<<<<<<<<<"
  echo "        - name: __not_implemented__   #<<<<<<<<<<<<<<<<<<<<<<<<"
  echo "      containers:"
  echo "        - name: __not_implemented__"
  echo "          image: ""__not_implemented__:__not_implemented__"
  echo "    ..."          
  echo -e "[./chart/${CHART_NAME}/values.yaml]"
  echo "or check out this chart example: https://github.com/open-toolchain/hello-helm/tree/master/chart/hello"
  echo "or refer to: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret"
  echo "    ..."
  echo "    image:"
  echo "repository: webapp"
  echo "  tag: 1"
  echo "  pullSecret: regsecret            #<<<<<<<<<<<<<<<<<<<<<<<<"
  echo "  pullPolicy: IfNotPresent"
  echo "    ..."
  echo "Enabling default serviceaccount to use the pull secret"
  kubectl patch -n ${CLUSTER_NAMESPACE} serviceaccount/default -p '{"imagePullSecrets":[{"name":"'"${IMAGE_PULL_SECRET_NAME}"'"}]}'
  echo "default serviceAccount:"
  kubectl get serviceAccount default -o yaml
  echo -e "Namespace ${CLUSTER_NAMESPACE} authorizing with private image registry using patched default serviceAccount"
else
  echo -e "Namespace ${CLUSTER_NAMESPACE} authorizing with private image registry using Helm chart imagePullSecret"
fi

echo -e "\\n=========================================================="
echo "CHECKING HELM VERSION: matching Helm Tiller (server) if detected. "
set +e
LOCAL_VERSION=$( helm version --client ${HELM_TLS_OPTION} | grep SemVer: | sed "s/^.*SemVer:\"v\([0-9.]*\).*/\1/" )
TILLER_VERSION=$( helm version --server ${HELM_TLS_OPTION} | grep SemVer: | sed "s/^.*SemVer:\"v\([0-9.]*\).*/\1/" )
set -e
if [ -z "${TILLER_VERSION}" ]; then
  if [ -z "${HELM_VERSION}" ]; then
    CLIENT_VERSION=${LOCAL_VERSION}
  else
    CLIENT_VERSION=${HELM_VERSION}
  fi
else
  echo -e "Helm Tiller ${TILLER_VERSION} already installed in cluster. Keeping it, and aligning client."
  CLIENT_VERSION=${TILLER_VERSION}
fi
if [ "${CLIENT_VERSION}" != "${LOCAL_VERSION}" ]; then
  echo -e "Installing Helm client ${CLIENT_VERSION}"
  WORKING_DIR=$(pwd)
  mkdir ~/tmpbin && cd ~/tmpbin
  curl -L https://storage.googleapis.com/kubernetes-helm/helm-v${CLIENT_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && tar -xzvf helm.tar.gz
  cd linux-amd64
  export PATH=$(pwd):$PATH
  cd $WORKING_DIR
fi
set +e
if [ -z "${TILLER_VERSION}" ]; then
    echo -e "Installing Helm Tiller ${CLIENT_VERSION} with cluster admin privileges (RBAC)"
    kubectl -n kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller ${HELM_TILLER_TLS_OPTION}
    # helm init --upgrade --force-upgrade
    kubectl --namespace=kube-system rollout status deploy/tiller-deploy
    # kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system
fi
set -e
helm version ${HELM_TLS_OPTION}

echo -e "\\n=========================================================="
echo -e "CHECKING HELM releases in this namespace: ${CLUSTER_NAMESPACE}"
helm list --namespace ${CLUSTER_NAMESPACE}

echo -e "\\n=========================================================="
echo "DEFINE RELEASE by prefixing image (app) name with namespace if not 'default' as Helm needs unique release names across namespaces"
if [[ "${CLUSTER_NAMESPACE}" != "default" ]]; then
  RELEASE_NAME="${CLUSTER_NAMESPACE}-${IMAGE_NAME}"
else
  RELEASE_NAME=${IMAGE_NAME}
fi
echo -e "Release name: ${RELEASE_NAME}"

echo -e "\\n=========================================================="
echo "DEPLOYING HELM chart"

# echo -e "\n==## Installing Helm 2.12.2"
# wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.2-linux-amd64.tar.gz
# tar -xzvf helm-v2.12.2-linux-amd64.tar.gz
# mkdir $HOME/helm212
# mv linux-amd64/helm $HOME/helm212/
# export PATH=$HOME/helm212:$PATH
# rm helm-v2.12.2-linux-amd64.tar.gz
    
# helm init --upgrade
# #--force-upgrade

IMAGE_REPOSITORY=${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}
IMAGE_PULL_SECRET_NAME="ibmcloud-toolchain-${PIPELINE_TOOLCHAIN_ID}-${REGISTRY_URL}"

INGRESS_SUBDOMAIN=$(ibmcloud ks cluster get --cluster ${PIPELINE_KUBERNETES_CLUSTER_NAME} | grep 'Ingress Subdomain' | awk '{ print $3 }')
INGRESS_HOST="todo.${INGRESS_SUBDOMAIN}"

INGRESS_SECRET=$(ibmcloud ks cluster get --cluster ${PIPELINE_KUBERNETES_CLUSTER_NAME} | grep 'Ingress Secret' | awk '{ print $3 }')

echo "##### ON REMPLACE AVEC LES VALEURS SUIVANTES:"
echo "INGRESS_SECRET=${INGRESS_SECRET}"
echo "RELEASE_NAME=${RELEASE_NAME}"
echo "CHART_PATH=${CHART_PATH}"
echo "image.repository=${IMAGE_REPOSITORY}"
echo "image.tag=${IMAGE_TAG}"
echo "image.pullSecret=${IMAGE_PULL_SECRET_NAME}"
echo "INGRESS_HOST=${INGRESS_HOST}"

# Using 'upgrade --install" for rolling updates. Note that subsequent updates will occur in the same namespace the release is currently deployed in, ignoring the explicit--namespace argument".
echo -e "Dry run into: ${PIPELINE_KUBERNETES_CLUSTER_NAME}/${CLUSTER_NAMESPACE}."
helm upgrade --install --debug --dry-run ${RELEASE_NAME} ${CHART_PATH} --set ingress.hosts[0]=${INGRESS_HOST},ingress.tls[0].hosts[0]=${INGRESS_HOST},ingress.tls[0].secretName=${INGRESS_SECRET},image.repository=${IMAGE_REPOSITORY},image.tag=${IMAGE_TAG},image.pullSecret=${IMAGE_PULL_SECRET_NAME} --namespace ${CLUSTER_NAMESPACE}

echo -e "Deploying into: ${PIPELINE_KUBERNETES_CLUSTER_NAME}/${CLUSTER_NAMESPACE}."
helm upgrade --install --debug ${RELEASE_NAME} ${CHART_PATH} --set ingress.hosts[0]=${INGRESS_HOST},ingress.tls[0].hosts[0]=${INGRESS_HOST},ingress.tls[0].secretName=${INGRESS_SECRET},image.repository=${IMAGE_REPOSITORY},image.tag=${IMAGE_TAG},image.pullSecret=${IMAGE_PULL_SECRET_NAME} --namespace ${CLUSTER_NAMESPACE}

echo -e "\\n=========================================================="
echo -e "CHECKING deployment status of release ${RELEASE_NAME} with image tag: ${IMAGE_TAG}"
echo ""
for ITERATION in {1..30}
do
  # DATA=$(kubectl get pods --namespace ${CLUSTER_NAMESPACE} -a -l release=${RELEASE_NAME} -o json )
  DATA=$(kubectl get pods --namespace ${CLUSTER_NAMESPACE} -l release=${RELEASE_NAME} -o json )
  NOT_READY=$( echo $DATA | jq '.items[].status.containerStatuses[] | select(.image=="'"${IMAGE_REPOSITORY}:${IMAGE_TAG}"'") | select(.ready==false) ' )
  if [[ -z "$NOT_READY" ]]; then
    echo -e "All pods are ready:"
    echo $DATA | jq '.items[].status.containerStatuses[] | select(.image=="'"${IMAGE_REPOSITORY}:${IMAGE_TAG}"'") | select(.ready==true) '
    break # deployment succeeded
  fi
  REASON=$(echo $DATA | jq '.items[].status.containerStatuses[] | select(.image=="'"${IMAGE_REPOSITORY}:${IMAGE_TAG}"'") | .state.waiting.reason')
  echo -e "${ITERATION} : Deployment still pending..."
  echo -e "NOT_READY:${NOT_READY}"
  echo -e "REASON: ${REASON}"
  if [[ ${REASON} == *ErrImagePull* ]] || [[ ${REASON} == *ImagePullBackOff* ]]; then
    echo "Detected ErrImagePull or ImagePullBackOff failure. "
    echo "Please check proper authenticating to from cluster to image registry (e.g. image pull secret)"
    break; # no need to wait longer, error is fatal
  elif [[ ${REASON} == *CrashLoopBackOff* ]]; then
    echo "Detected CrashLoopBackOff failure. "
    echo "Application is unable to start, check the application startup logs"
    break; # no need to wait longer, error is fatal
  fi
  sleep 5
done

if [[ ! -z "$NOT_READY" ]]; then
  echo ""
  echo -e "\\n=========================================================="
  echo "DEPLOYMENT FAILED"
  echo "Deployed Services:"
  kubectl describe services ${RELEASE_NAME}-${CHART_NAME} --namespace ${CLUSTER_NAMESPACE}
  echo ""
  echo "Deployed Pods:"
  kubectl describe pods --selector app=${CHART_NAME} --namespace ${CLUSTER_NAMESPACE}
  echo ""
  echo "Application Logs"
  kubectl logs --selector app=${CHART_NAME} --namespace ${CLUSTER_NAMESPACE}
  echo "=========================================================="
  PREVIOUS_RELEASE=$( helm history ${RELEASE_NAME} | grep SUPERSEDED | sort -r -n | awk '{print $1}' | head -n 1 )
  echo -e "Could rollback to previous release: ${PREVIOUS_RELEASE} using command:"
  echo -e "helm rollback ${RELEASE_NAME} ${PREVIOUS_RELEASE}"
  # helm rollback ${RELEASE_NAME} ${PREVIOUS_RELEASE}
  # echo -e "History for release:${RELEASE_NAME}"
  # helm history ${RELEASE_NAME}
  # echo "Deployed Services:"
  # kubectl describe services ${RELEASE_NAME}-${CHART_NAME} --namespace ${CLUSTER_NAMESPACE}
  # echo ""
  # echo "Deployed Pods:"
  # kubectl describe pods --selector app=${CHART_NAME} --namespace ${CLUSTER_NAMESPACE}
  exit 1
fi

echo ""
echo -e "\\n=========================================================="
echo "DEPLOYMENT SUCCEEDED"
echo ""
echo -e "Status for release:${RELEASE_NAME}"
helm status ${RELEASE_NAME}

echo ""
echo -e "History for release:${RELEASE_NAME}"
helm history ${RELEASE_NAME}

# echo ""
# echo "Deployed Services:"
# kubectl describe services ${RELEASE_NAME}-${CHART_NAME} --namespace ${CLUSTER_NAMESPACE}
# echo ""
# echo "Deployed Pods:"
# kubectl describe pods --selector app=${CHART_NAME} --namespace ${CLUSTER_NAMESPACE}

#echo "=========================================================="
#IP_ADDR=$(ibmcloud ks workers ${PIPELINE_KUBERNETES_CLUSTER_NAME} | grep normal | head -n 1 | awk '{ print $2 }')
#PORT=$(kubectl get services --namespace ${CLUSTER_NAMESPACE} | grep ${RELEASE_NAME} | sed 's/.*:\([0-9]*\).*/\1/g')
#echo -e "View the application at: http://${IP_ADDR}:${PORT}"
