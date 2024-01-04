#! /bin/sh

echo '--------------- Create the AKS cluster resource group ---------------'
echo 'Set AKS_RG_LOCATION='eastus2''
export AKS_RG_LOCATION='eastus2'
echo 'Set AKS_RG_NAME='rg-bu0001a0008''
export AKS_RG_NAME='rg-bu0001a0008'
echo 'AKS_RG_NAME: ' $AKS_RG_NAME
echo 'Create Resource Group: ' $AKS_RG_NAME
# [This takes less than one minute.]
az group create --name $AKS_RG_NAME --location $AKS_RG_LOCATION
echo '--------------- Create the AKS cluster resource group Completed ---------------'
echo '------------------------------------------------------------------------------'

echo '--------------- Get the AKS cluster spoke Virtual Network resource ID ---------------'
echo 'Set NETWORKING_SPOKE_RG_NAME='rg-enterprise-networking-spokes''
export NETWORKING_SPOKE_RG_NAME='rg-enterprise-networking-spokes'
echo 'Set the SUBNET_NODEPOOLS_DEPLOYMENT_NAME='spoke-BU0001A0008''
export SUBNET_NODEPOOLS_DEPLOYMENT_NAME='spoke-BU0001A0008'
export RESOURCEID_VNET_CLUSTERSPOKE_AKS_BASELINE=$(az deployment group show -g $NETWORKING_SPOKE_RG_NAME -n $SUBNET_NODEPOOLS_DEPLOYMENT_NAME --query properties.outputs.clusterVnetResourceId.value -o tsv)
echo RESOURCEID_VNET_CLUSTERSPOKE_AKS_BASELINE: $RESOURCEID_VNET_CLUSTERSPOKE_AKS_BASELINE
echo '--------------- Get the AKS cluster spoke Virtual Network resource ID Completed ---------------'
echo '------------------------------------------------------------------------------'

echo '--------------- Deploy the container registry and non-stamp resources template ---------------'
echo 'Set AKS_RG_LOCATION='eastus2''
export AKS_RG_LOCATION='eastus2'
# [This takes about four minutes.]
az deployment group create -g $AKS_RG_NAME -f ../acr-stamp.bicep -p targetVnetResourceId=${RESOURCEID_VNET_CLUSTERSPOKE_AKS_BASELINE} location=$AKS_RG_LOCATION
echo '--------------- Deploy the container registry and non-stamp resources template Completed ---------------'
echo '------------------------------------------------------------------------------'

echo '--------------- Import cluster management images to your container registry ---------------'
# Get your ACR instance name
export ACR_NAME_AKS_BASELINE=$(az deployment group show -g $AKS_RG_NAME -n acr-stamp --query properties.outputs.containerRegistryName.value -o tsv)
echo ACR_NAME_AKS_BASELINE: $ACR_NAME_AKS_BASELINE
echo 'Import core image(s) hosted in public container registries to be used during bootstrapping'
az acr import --source ghcr.io/kubereboot/kured:1.14.0 -n $ACR_NAME_AKS_BASELINE -g $AKS_RG_NAME --force
echo '--------------- Import cluster management images to your container registry Completed ---------------'
echo '------------------------------------------------------------------------------'

echo '--------------- Update bootstrapping manifests to pull from your Azure Container Registry ---------------'
echo 'Replace the ghcr.io/kubereboot/kured:1.14.0 image with $ACR_NAME_AKS_BASELINE.azurecr.io/kured:1.14.0'
sed -i "s:ghcr.io:${ACR_NAME_AKS_BASELINE}.azurecr.io:" k8s/kured-template.yaml > k8s/kured.yaml


