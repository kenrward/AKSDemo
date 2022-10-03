#!/bin/bash
prefix="croc"

az group create -n "${prefix}-RG" --location eastus

output=$(az deployment group create -n "${prefix}-Deployment" \
-g "${prefix}-RG" \
--template-file deploy.bicep \
--parameters @local.settings.json)


az aks create \
    --resource-group "${prefix}-RG"  \
    --name "${prefix}-aksCluster"  \
    --network-plugin azure \
    --vnet-subnet-id /subscriptions/76a7f190-b557-40f6-a02e-96df8d0b7fa6/resourceGroups/knox-RG/providers/Microsoft.Network/virtualNetworks/doit-vnet/subnets/doit-ask-subnet \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.1.3.10 \
    --service-cidr 10.1.3.0/24 \
    --generate-ssh-keys

az aks get-credentials \
--resource-group "${prefix}-RG" \
--name "${prefix}-aksCluster" 

#  export KUBECONFIG=/mnt/c/Users/kenrw/.kube/config 

# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

kubectl 