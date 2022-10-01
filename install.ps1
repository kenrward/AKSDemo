az group create --name myResourceGroup --location eastus

az aks create -g myResourceGroup -n myAKSCluster `
--enable-managed-identity `
--node-count 1 `
--enable-addons monitoring `
--enable-msi-auth-for-monitoring  `
--generate-ssh-keys

az aks install-cli

az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

kubectl get nodes

# https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#code-try-6
# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/