#!/bin/bash
prefix="five"

az group create -n "${prefix}-RG" --location eastus

az deployment group create -n "${prefix}-Deployment"  \
  -g "${prefix}-RG" \
  --template-file deploy.bicep \
  --parameters @local.settings.json \
  --parameters prefix=$prefix

az deployment group show \
  -g "${prefix}-RG" \
  -n "${prefix}-Deployment" \
  --query properties.outputs.strStrAccount.value

vnet_sub_id=$(az deployment group show \
  -g "${prefix}-RG" \
  -n "${prefix}-Deployment" \
  --query properties.outputs.aksSubNetID.value -o tsv)


az aks create \
    --resource-group "${prefix}-RG"  \
    --name "${prefix}-aksCluster"  \
    --network-plugin azure \
    --vnet-subnet-id $(az deployment group show \
        -g "${prefix}-RG" \
        -n "${prefix}-Deployment" \
        --query properties.outputs.aksSubNetID.value -o tsv) \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.1.3.10 \
    --service-cidr 10.1.3.0/24 \
    --generate-ssh-keys

az aks get-credentials \
--resource-group "${prefix}-RG" \
--name "${prefix}-aksCluster" 

# export KUBECONFIG=/mnt/c/Users/kenrw/.kube/config 

# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

kubectl 

cd k8-wordpressapp

kubectl apply -k ./