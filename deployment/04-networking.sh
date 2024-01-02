#! /bin/sh

#set location variable
echo "Setting location variable"
export location='eastus'

# set resource group variables
echo "Setting resource group variables"
export RESOURCEGROUP_VNET_HUB='rg-enterprise-networking-hubs'
export RESOURCEGROUP_VNET_SPOKE='rg-enterprise-networking-spokes'

# Create resource group '$RESOURCEGROUP_VNET_HUB'
echo "Creating resource group '$RESOURCEGROUP_VNET_HUB'"
az group create -n $RESOURCEGROUP_VNET_HUB -l $location
echo "Created resource group '$RESOURCEGROUP_VNET_HUB'"

# Create resouce group '$RESOURCEGROUP_VNET_SPOKE'
echo "Creating resource group '$RESOURCEGROUP_VNET_SPOKE'"
az group create -n $RESOURCEGROUP_VNET_SPOKE -l $location
echo "Created resource group '$RESOURCEGROUP_VNET_SPOKE'"

# Create deployment for hub-default.bicep
echo "Creating deployment for hub-default.bicep"
# [This takes about six minutes to run.]
az deployment group create -g $RESOURCEGROUP_VNET_HUB -f ../networking/hub-default.bicep -p location=$location
echo "----------------------------------------"
echo "Created deployment for hub-default.bicep"

# set RESOURCEID_VNET_HUB variable
echo "Setting RESOURCEID_VNET_HUB variable"
RESOURCEID_VNET_HUB=$(az deployment group show -g $RESOURCEGROUP_VNET_HUB -n hub-default --query properties.outputs.hubVnetId.value -o tsv)
echo RESOURCEID_VNET_HUB: $RESOURCEID_VNET_HUB

# Create deployment for spoke-BU0001A0008.bicep
echo "Creating deployment for spoke-BU0001A0008.bicep"
# [This takes about four minutes to run.]
az deployment group create -g $RESOURCEGROUP_VNET_SPOKE -f ../networking/spoke-BU0001A0008.bicep -p location=$location hubVnetResourceId="${RESOURCEID_VNET_HUB}"
echo "----------------------------------------"
echo "Created deployment for spoke-BU0001A0008.bicep"

# set RESOURCEID_SUBNET_NODEPOOLS variable
echo "Setting RESOURCEID_SUBNET_NODEPOOLS variable"
RESOURCEID_SUBNET_NODEPOOLS=$(az deployment group show -g $RESOURCEGROUP_VNET_SPOKE -n spoke-BU0001A0008 --query properties.outputs.nodepoolSubnetResourceIds.value -o json)
echo RESOURCEID_SUBNET_NODEPOOLS: $RESOURCEID_SUBNET_NODEPOOLS

# Create deployment for hub-regionA.bicep
echo "Creating deployment for hub-regionA.bicep"
# [This takes about ten minutes to run.]
az deployment group create -g $RESOURCEGROUP_VNET_HUB -f ../networking/hub-regionA.bicep -p location=eastus2 nodepoolSubnetResourceIds="${RESOURCEID_SUBNET_NODEPOOLS}"
echo "----------------------------------------"
echo "Created deployment for hub-regionA.bicep"




