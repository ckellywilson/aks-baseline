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


