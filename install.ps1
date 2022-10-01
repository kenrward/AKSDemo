az group create --name myResourceGroup --location eastus

az aks create -g myResourceGroup -n myAKSCluster `
--enable-managed-identity `
--node-count 1 `
--enable-addons monitoring `
--enable-msi-auth-for-monitoring  `
--generate-ssh-keys

az aks install-cli

az aks get-credentials --resource-group  --name myAKSCluster

kubectl get nodes

$vnet=az network vnet list --query "[?contains(addressSpace.addressPrefixes, '10.224.0.0/12')].name" -o tsv
myResourceGroup
az network vnet subnet list --resource-group myResourceGroup --vnet-name $vnet

# private AKS
# https://learn.microsoft.com/en-us/azure/aks/private-clusters

# https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#code-try-6
# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

# Error Lookup
# https://komodor.com/learn/how-to-fix-createcontainerconfigerror-and-createcontainer-errors/

# Mongo DB
# https://www.mongodb.com/docs/v4.2/tutorial/install-mongodb-on-ubuntu/

# Ubuntu 16.04 (Xenial)
az vm image list --all --publisher Canonical --sku 16.04.0-LTS

az vm create `
  --resource-group myResourceGroup `
  --name myVM `
  --image Canonical:UbuntuServer:16.04.0-LTS:16.04.201608300 `
  --admin-username azureuser `
  --generate-ssh-keys