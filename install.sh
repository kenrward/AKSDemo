#!/bin/bash
prefix="rbac"

az group create -n "${prefix}-RG" --location eastus

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


az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee-object-id $MI \
    --assignee-principal-type ServicePrincipal \
    --scope "/subscriptions/76a7f190-b557-40f6-a02e-96df8d0b7fa6/resourceGroups/${prefix}-RG/providers/Microsoft.Storage/storageAccounts/$strAcct/blobServices/default/containers/publicbackup"

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
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts

# VM backup

sshCommand=$(az deployment group show \
  -g "${prefix}-RG" \
  -n "${prefix}-Deployment" \
  --query properties.outputs.sshCommand.value -o tsv)

echo $sshCommand

mod_hostname="mntgoat@$hostName /home/mntgoat"
colonPATHS=$(echo "$mod_hostname" | sed -r 's/\s+/:/g')

cd ..

scp postDeploy.sh $colonPATHS



