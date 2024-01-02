#! /bin/sh

# set location variable
export location='eastus2'

# set resource group variables
export RESOURCEGROUP_VNET_HUB='rg-bu0001a0008'
export RESOURCEGROUP_VNET_SPOKE='rg-enterprise-networking-spokes'

# Create resource group '$RESOURCEGROUP_VNET_HUB'
echo "Creating resource group '$RESOURCEGROUP_VNET_HUB'"
az group create -n $RESOURCEGROUP_VNET_HUB -l $location
echo "Created resource group '$RESOURCEGROUP_VNET_HUB'"

