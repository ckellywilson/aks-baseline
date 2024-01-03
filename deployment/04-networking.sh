#! /bin/sh

echo '--------------- Create Networking Hub Resource Group ---------------'
echo 'Set HUB_RG_LOCATION='centralus''
export HUB_RG_LOCATION='centralus'
echo 'Set NETWORKING_HUB_RG_NAME='rg-enterprise-networking-hubs''
export NETWORKING_HUB_RG_NAME='rg-enterprise-networking-hubs'
echo 'Networking Hub Resource Group Name: ' $NETWORKING_HUB_RG_NAME
az group create --name $NETWORKING_HUB_RG_NAME --location $HUB_RG_LOCATION
echo '--------------- Create Networking Hub Resource Group Completed ---------------'
echo '------------------------------------------------------------------------------'

echo '--------------- Create Networking Spoke Resource Group ---------------'
echo 'Set SPOKE_RG_LOCATION='centralus''
export SPOKE_RG_LOCATION='centralus'
echo 'Set NETWORKING_SPOKE_RG_NAME='rg-enterprise-networking-spokes''
export NETWORKING_SPOKE_RG_NAME='rg-enterprise-networking-spokes'
echo 'Networking Spoke Resource Group Name: ' $NETWORKING_SPOKE_RG_NAME
az group create --name $NETWORKING_SPOKE_RG_NAME --location $SPOKE_RG_LOCATION
echo '--------------- Create Networking Spoke Resource Group Completed ---------------'
echo '------------------------------------------------------------------------------'

echo '--------------- Create Regional Network Hub ---------------'
echo 'Set NETWORKING_HUB_LOCATION='eastus2''
export NETWORKING_HUB_LOCATION='eastus2'
echo 'Set NETWORKING_HUB_RG_NAME='rg-enterprise-networking-hubs''
export NETWORKING_HUB_RG_NAME='rg-enterprise-networking-hubs'
echo 'Create deployment group for '$NETWORKING_HUB_RG_NAME''
az deployment group create --resource-group $NETWORKING_HUB_RG_NAME --template-file ../networking/hub-default.bicep --parameters ../networking/hub-default.bicepparam
echo '--------------- Create Regional Network Hub Completed ---------------'
echo '------------------------------------------------------------------------------'

echo '--------------- Create Regional Network Spoke ---------------'
echo 'Set NETWORKING_SPOKE_LOCATION='eastus2''
export NETWORKING_SPOKE_LOCATION='eastus2'
echo 'Set NETWORKING_SPOKE_RG_NAME='rg-enterprise-networking-spokes''
export NETWORKING_SPOKE_RG_NAME='rg-enterprise-networking-spokes'
echo 'Set RESOURCEID_VNET_HUB'
RESOURCEID_VNET_HUB=$(az deployment group show -g $NETWORKING_HUB_RG_NAME -n hub-default --query properties.outputs.hubVnetId.value -o tsv)
echo RESOURCEID_VNET_HUB: $RESOURCEID_VNET_HUB

echo 'Create deployment group for '$NETWORKING_SPOKE_RG_NAME''
# [This takes about four minutes to run.]
az deployment group create -g $NETWORKING_SPOKE_RG_NAME -f ../networking/spoke-BU0001A0008.bicep -p location=$NETWORKING_HUB_LOCATION hubVnetResourceId="${RESOURCEID_VNET_HUB}"
echo '--------------- Create Regional Network Spoke Completed ---------------'
echo '------------------------------------------------------------------------------'


echo '--------------- Update the shared, regional hub deployment to account for the requirements of the spoke ---------------'
echo 'Set SUBNET_NODEPOOLS_LOCATION='eastus2''
export SUBNET_NODEPOOLS_LOCATION='eastus2'
echo 'Set RESOURCEID_SUBNET_NODEPOOLS'
echo 'Set the SUBNET_NODEPOOLS_DEPLOYMENT_NAME='spoke-BU0001A0008''
export SUBNET_NODEPOOLS_DEPLOYMENT_NAME='spoke-BU0001A0008'
RESOURCEID_SUBNET_NODEPOOLS=$(az deployment group show -g $NETWORKING_SPOKE_RG_NAME -n $SUBNET_NODEPOOLS_DEPLOYMENT_NAME --query properties.outputs.nodepoolSubnetResourceIds.value -o json)
echo RESOURCEID_SUBNET_NODEPOOLS: $RESOURCEID_SUBNET_NODEPOOLS
echo 'Create deployment group for '$RESOURCEID_SUBNET_NODEPOOLS''
# [This takes about ten minutes to run.]
az deployment group create -g $NETWORKING_HUB_RG_NAME -f ../networking/hub-regionA.bicep -p location=$SUBNET_NODEPOOLS_LOCATION nodepoolSubnetResourceIds="${RESOURCEID_SUBNET_NODEPOOLS}"
echo '--------------- Update the shared, regional hub deployment to account for the requirements of the spoke Completed ---------------'
echo '------------------------------------------------------------------------------'


