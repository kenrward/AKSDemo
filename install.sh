#!/bin/bash
prefix="dev"

az group create -n "${prefix}-RG" --location eastus

# az acr create -g "${prefix}-RG" \
#   -n "${prefix}acr1011" --sku Basic

# az aks update -n "${prefix}-aksCluster" -g "${prefix}-RG" --attach-acr "${prefix}acr1011"

az deployment group create -n "${prefix}-Deployment"  \
  -g "${prefix}-RG" \
  --template-file deploy.bicep \
  --parameters @local.settings.json \
  --parameters prefix=$prefix

MI=$(az deployment group show \
  -g "${prefix}-RG" \
  -n "${prefix}-Deployment" \
  --query properties.outputs.managedID.value -o tsv)

strAcct=$(az deployment group show \
  -g "${prefix}-RG" \
  -n "${prefix}-Deployment" \
  --query properties.outputs.strStrAccount.value -o tsv)

hostName=$(az deployment group show \
  -g "${prefix}-RG" \
  -n "${prefix}-Deployment" \
  --query properties.outputs.hostname.value -o tsv)

subID=$(az account show --query id --output tsv)


az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee-object-id $MI \
    --assignee-principal-type ServicePrincipal \
    --scope "/subscriptions/$subID/resourceGroups/${prefix}-RG/providers/Microsoft.Storage/storageAccounts/$strAcct/blobServices/default/containers/publicbackup"

az aks get-credentials \
--resource-group "${prefix}-RG" \
--name "${prefix}-aksCluster" 

export KUBECONFIG=/mnt/c/Users/kenrw/.kube/config 

# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

# kubectl 

cd k8-wordpressapp

kubectl apply -k ./

kubectl get services

# kubectl create clusterrolebasedbinding cluster-admin --clusterrole=cluster-admin 
 kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:wp-cluster-admin 


# VM backup

sshCommand=$(az deployment group show \
  -g "${prefix}-RG" \
  -n "${prefix}-Deployment" \
  --query properties.outputs.sshCommand.value -o tsv)

echo $sshCommand

mod_hostname="mntgoat@$hostName /home/mntgoat"
colonPATHS=$(echo "$mod_hostname" | sed -r 's/\s+/:/g')

cd ../postDeploy

scp postDeploy.sh $colonPATHS

$mod_hostname="mntgoat@$hostName /etc"
$colonPATHS=$(echo "$mod_hostname" | sed -r 's/\s+/:/g')

scp mongod.conf $colonPATHS



