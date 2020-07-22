#!/bin/bash
# uncomment to debug the script
#set -x
# copy the script below into your app code repo (e.g. ./scripts/build_image.sh) and 'source' it from your pipeline job
#    source ./scripts/build_image.sh
# alternatively, you can source it from online script:
#    source <(curl -sSL "https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/build_image.sh")
# ------------------
# source: https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/build_image.sh
echo "Build environment variables:"
echo "REGISTRY_URL=${REGISTRY_URL}"
echo "REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE}"
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "BUILD_NUMBER=${BUILD_NUMBER}"
echo "ARCHIVE_DIR=${ARCHIVE_DIR}"
echo "GIT_COMMIT=${GIT_COMMIT}"

# also run 'env' command to find all available env variables
# or learn more about the available environment variables at:
# https://console.bluemix.net/docs/services/ContinuousDelivery/pipeline_deploy_var.html#deliverypipeline_environment

# To review or change build options use:
# bx cr build --help

echo -e "\\n=========================================================="
echo "CHECKING DOCKERFILE"
echo "Checking Dockerfile at the repository root"
if [ -f Dockerfile ]; then 
  echo "Dockerfile found"
else
    echo "Dockerfile not found"
    exit 1
fi

echo "Linting Dockerfile"
npm install -g dockerlint
dockerlint -f Dockerfile

# echo -e "Existing images in registry"
# bx cr images

TIMESTAMP=$( date -u "+%Y%m%d%H%M%SUTC")
IMAGE_TAG=${BUILD_NUMBER}-${TIMESTAMP}
if [ ! -z ${GIT_COMMIT} ]; then
  GIT_COMMIT_SHORT=$( echo ${GIT_COMMIT} | head -c 8 ) 
  IMAGE_TAG=${IMAGE_TAG}-${GIT_COMMIT_SHORT}; 
fi

echo -e "\\n=========================================================="
echo -e "BUILDING CONTAINER IMAGE: ${IMAGE_NAME}:${IMAGE_TAG}"
set -x
bx cr build -t ${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG} .
set +x
bx cr image-inspect ${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}

# Set PIPELINE_IMAGE_URL for subsequent jobs in stage (e.g. Vulnerability Advisor)
export PIPELINE_IMAGE_URL="$REGISTRY_URL/$REGISTRY_NAMESPACE/$IMAGE_NAME:$BUILD_NUMBER"

bx cr images --restrict ${REGISTRY_NAMESPACE}/${IMAGE_NAME}

echo -e "\\n=========================================================="
echo "CHECKING HELM CHART"
CHART_ROOT="./.cloud/chart"
if [ -d ${CHART_ROOT} ]; then
  CHART_NAME=$(find ${CHART_ROOT}/. -maxdepth 2 -type d -name '[^.]?*' -printf %f -quit)
  CHART_PATH=${CHART_ROOT}/${CHART_NAME}
fi
if [ -z "${CHART_PATH}" ]; then
    echo -e "No Helm chart found for Kubernetes deployment under ${CHART_ROOT}/<CHART_NAME>."
    exit 1
else
    echo -e "Helm chart found for Kubernetes deployment : ${CHART_PATH}"
fi
echo "Linting Helm Chart"
helm lint ${CHART_PATH}

echo "Copy Helm chart along with the build"
if [ ! -d $ARCHIVE_DIR/CHART_ROOT ]; then # no need to copy if working in ./ already
  cp -r $CHART_ROOT $ARCHIVE_DIR/
fi

echo -e "\\n=========================================================="
echo "COPYING ARTIFACTS needed for deployment and testing (in particular build.properties)"

echo "Checking archive dir presence"
mkdir -p $ARCHIVE_DIR

# Persist env variables into a properties file (build.properties) so that all pipeline stages consuming this
# build as input and configured with an environment properties file valued 'build.properties'
# will be able to reuse the env variables in their job shell scripts.

# CHART information from build.properties is used in Helm Chart deployment to set the release name
echo "CHART_NAME=${CHART_NAME}" >> $ARCHIVE_DIR/build.properties
echo "CHART_PATH=${CHART_PATH}" >> $ARCHIVE_DIR/build.properties
# IMAGE information from build.properties is used in Helm Chart deployment to set the release name
echo "IMAGE_NAME=${IMAGE_NAME}" >> $ARCHIVE_DIR/build.properties
echo "IMAGE_TAG=${IMAGE_TAG}" >> $ARCHIVE_DIR/build.properties
# REGISTRY information from build.properties is used in Helm Chart deployment to generate cluster secret
echo "REGISTRY_URL=${REGISTRY_URL}" >> $ARCHIVE_DIR/build.properties
echo "REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE}" >> $ARCHIVE_DIR/build.properties
echo "File 'build.properties' created for passing env variables to subsequent pipeline jobs:"
cat $ARCHIVE_DIR/build.properties

echo "Copy pipeline scripts along with the build"
# Copy scripts (incl. deploy scripts)
if [ -d ./scripts/ ]; then
  if [ ! -d $ARCHIVE_DIR/scripts/ ]; then # no need to copy if working in ./ already
    cp -r ./scripts/ $ARCHIVE_DIR/
  fi
fi

echo "Copy Helm chart along with the build"
if [ ! -d $ARCHIVE_DIR/chart/ ]; then # no need to copy if working in ./ already
  cp -r ./chart/ $ARCHIVE_DIR/
fi
