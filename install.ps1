# private AKS
# https://learn.microsoft.com/en-us/azure/aks/private-clusters

# https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#code-try-6
# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/
# https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni

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

$prefix = "Ravens"
  az group create -n "${prefix}-RG" --location eastus

  az deployment group create -n "${prefix}-Deployment" -g "${prefix}-RG" --template-file .\deploy.bicep 


## NEW


az network vnet create `
    --resource-group "${prefix}-RG" `
    --name "aksd-vnet" `
    --address-prefixes 192.168.0.0/16 `
    --subnet-name deAKSSubnet `
    --subnet-prefix 192.168.1.0/24

subnetID=$(az network vnet subnet show --resource-group "${prefix}-RG" --vnet-name "aksd-vnet" --name deAKSSubnet --query id -o tsv)