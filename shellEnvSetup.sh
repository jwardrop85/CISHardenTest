#!/bin/bash
# call using . ./shellEnvSetup.sh to get the env vars to stay in current shell context (that really is a leading dot then space then ./zz-tfenv-emt-prd.sh)
export SUBSCRIPTION_ID=87d06e40-ebe1-4537-a9c4-2d4670a82b9d

az login
az account set --subscription $SUBSCRIPTION_ID

export ARM_CLIENT_ID="$(az keyvault secret show --vault-name kv-dev-core --name client-id --query value -otsv)"
export ARM_CLIENT_SECRET="$(az keyvault secret show --vault-name kv-dev-core --name client-secret --query value -otsv)"
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_TENANT_ID=d9623dfe-e086-4f27-b0f6-a7c8b1254c7a
PATH=$PATH:/opt/terraform
export PATH