#!/bin/bash
<<<<<<< HEAD
prefix="q34"
=======
prefix="oct"
>>>>>>> 5f5112a5141c6b2e3109b66b4d6ee5046d394b55

az group create -n "${prefix}-RG" --location eastus

az deployment group create -n "${prefix}-Deployment"  \
  -g "${prefix}-RG" \
  --template-file deploy.bicep \
  --parameters @local.settings.json \
  --parameters prefix=$prefix


az aks get-credentials \
--resource-group "${prefix}-RG" \
--name "${prefix}-aksCluster" 

export KUBECONFIG=/mnt/c/Users/kenrw/.kube/config 

# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

# kubectl 

cd k8-wordpressapp

kubectl apply -k ./
