#! /bin/sh


echo '-------------------- Set TENANTID_AZURERBAC_AKS_BASELINE ---------------------'
export TENANTID_AZURERBAC_AKS_BASELINE=$(az account show --query tenantId -o tsv)
echo TENANTID_AZURERBAC_AKS_BASELINE: $TENANTID_AZURERBAC_AKS_BASELINE


echo '-------------------- Create Cluster Admin Group 'cluster-admins-bu0001a000800' ---------------------'
export CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME='cluster-admins-bu0001a000800'
echo CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME: $CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME

echo Create cluster admin group '$CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME'
az ad group create --display-name $CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME --mail-nickname $CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME --description "Principals in this group are cluster admins in the bu0001a000800 cluster."
echo cluster admin group '$CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME' created

echo Set MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE
export MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE=$(az ad group list --query "[?displayName=='$CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME'].id" -o tsv)
echo MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE: $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE
echo '-------------------- Create Cluster Admin Group 'cluster-admins-bu0001a000800' complete ---------------------'
echo '-------------------------------------------------------------------------------------------------------------'

echo '---------------------- Assign Signed-in User to '$CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME' ----------------------'
echo 'Retrieve the MEID of the signed-in user'
export MEID_SIGNEDINUSER_AKS_BASELINE=$(az ad signed-in-user show --query id -o tsv)
echo 'MEID_SIGNEDINUSER_AKS_BASELINE: '$MEID_SIGNEDINUSER_AKS_BASELINE''
echo 'Assign signed-in user to '$CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME''
az ad group member add --group $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE --member-id $MEID_SIGNEDINUSER_AKS_BASELINE
echo '---------------- Assign signed-in user to '$CLUSTERADMIN_SERVICE_ACCOUNT_GROUP_NAME' complete ------------------'
echo '-------------------------------------------------------------------------------------------------------------'

echo '---------------------- Create Namespace Reader Role 'cluster-ns-a0008-readers-bu0001a000800' ----------------------'
export NAMESPACE_READER_ROLE_NAME='cluster-ns-a0008-readers-bu0001a000800'
export NAMESPACE_READER_ROLE_NAME='cluster-ns-a0008-readers-bu0001a000800'
echo 'Create namespace reader group '$NAMESPACE_READER_ROLE_NAME''
az ad group create --display-name $NAMESPACE_READER_ROLE_NAME --mail-nickname $NAMESPACE_READER_ROLE_NAME --description "Principals in this group are readers of namespace a0008 in the bu0001a000800 cluster."
export MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE=$(az ad group list --query "[?displayName=='$NAMESPACE_READER_ROLE_NAME'].id" -o tsv)
echo MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE: $MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE
echo '---------------------- Create Namespace Reader Role 'cluster-ns-a0008-readers-bu0001a000800' complete ----------------------'
echo '-------------------------------------------------------------------------------------------------------------'

echo 'Replace <replace-with-a-microsoft-entra-group-object-id-for-this-cluster-role-binding> with '$MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE''
sed "s/<replace-with-a-microsoft-entra-group-object-id-for-this-cluster-role-binding>/$MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE/g" k8s/cluster-rbac-template.yaml > k8s/cluster-rbac.yaml
echo Replace '<replace-with-a-microsoft-entra-group-object-id-for-this-cluster-role-binding> with '$MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE' complete'
echo '-------------------------------------------------------------------------------------------------------------'

echo 'Replace <replace-with-a-microsoft-entra-group-object-id-for-this-namespace-role-binding> in k8s/namespace-rbac-template.yaml with '$MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE''
sed "s/<replace-with-a-microsoft-entra-group-object-id-for-this-namespace-role-binding>/$MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE/g" k8s/namespace-rbac-template.yaml > k8s/namespace-rbac.yaml
echo 'Replace <replace-with-a-microsoft-entra-group-object-id-for-this-namespace-role-binding> in k8s/namespace-rbac-template.yaml with '$MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE' complete'
echo '-------------------------------------------------------------------------------------------------------------'



