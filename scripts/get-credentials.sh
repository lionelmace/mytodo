#!/bin/bash
# Retrieve the values to be used in the credentials.env file

if [ -z "$REGION" ]; then
  export REGION=$(ibmcloud target | grep Region | awk '{print $2}')
fi

CLOUDANT_GUID=$(ibmcloud resource service-instance --id secure-file-storage-cloudant | awk '{print $2}')
CLOUDANT_CREDENTIALS=$(ibmcloud resource service-key secure-file-storage-cloudant-acckey-$CLOUDANT_GUID)
CLOUDANT_ACCOUNT=$(echo "$CLOUDANT_CREDENTIALS" | grep username | awk '{ print $2 }')
CLOUDANT_IAM_APIKEY=$(echo "$CLOUDANT_CREDENTIALS" | sort | grep apikey -m 1 | awk '{ print $2 }')
CLOUDANT_DATABASE=secure-file-storage-metadata

echo "# Cloudant Credentials
cloudant_account=$CLOUDANT_ACCOUNT
cloudant_iam_apikey=$CLOUDANT_IAM_APIKEY
cloudant_database=$CLOUDANT_DATABASE
"