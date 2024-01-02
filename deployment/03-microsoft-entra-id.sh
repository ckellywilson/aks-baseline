#! /bin/sh

# set LOCATION_AKS_BASELINE='eastus'
echo "set LOCATION_AKS_BASELINE='eastus'"
export LOCATION_AKS_BASELINE='eastus'
echo LOCATION_AKS_BASELINE: $LOCATION_AKS_BASELINE

# set MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME='cluster-admins-bu0001a000800'
echo "set MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME='cluster-admins-bu0001a000800'"
export MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME='cluster-admins-bu0001a000800'
echo MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME: $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME

# set MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME='cluster-admin-bu0001a000800'
echo "set MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME='cluster-admin-bu0001a000800'"
export MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME='cluster-admin-bu0001a000800'
echo MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME: $MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME

# Set MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE_DISPLAYNAME='cluster-ns-a0008-readers-bu0001a000800'
export MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE_DISPLAYNAME='cluster-ns-a0008-readers-bu0001a000800'
echo MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE_DISPLAYNAME: $MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE_DISPLAYNAME

# Query and save your Azure subscription's tenant ID
export TENANTID_AZURERBAC_AKS_BASELINE=$(az account show --query tenantId -o tsv)
echo TENANTID_AZURERBAC_AKS_BASELINE: $TENANTID_AZURERBAC_AKS_BASELINE

# Set TENANTID_K8SRBAC_AKS_BASELINE.
# NOTE: Skip login, as we will use the same tenant
# az login -t <Replace-With-ClusterApi-AzureAD-TenantId> --allow-no-subscriptions
export TENANTID_K8SRBAC_AKS_BASELINE=$(az account show --query tenantId -o tsv)
echo TENANTID_K8SRBAC_AKS_BASELINE: $TENANTID_K8SRBAC_AKS_BASELINE

# Create az ad group
echo "Create az ad group for $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME"
az ad group create --display-name $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME --mail-nickname $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME --description "Principals in this group are cluster admins in the bu0001a000800 cluster."
export MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE=$(az ad group list --query "[?displayName=='$MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAYNAME'].id" -o tsv)
echo MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE: $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE

# Create a "break-glass" cluster administrator user for your AKS cluster
TENANTDOMAIN_K8SRBAC=$(az ad signed-in-user show --query 'userPrincipalName' -o tsv | cut -d '@' -f 2 | sed 's/\"//')

# Create ad user az ad user '$MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME'
echo "Create ad user az ad user '$MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME'"
az ad user create --display-name=${MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME} --user-principal-name ${MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME}@${TENANTDOMAIN_K8SRBAC} --force-change-password-next-sign-in --password ChangeMebu0001a0008AdminChangeMe --query id -o tsv
echo "Created ad user az ad user '$MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME'"

# Set MEIDOBJECTID_USER_CLUSTERADMIN
echo "Set MEIDOBJECTID_USER_CLUSTERADMIN"
MEIDOBJECTID_USER_CLUSTERADMIN=$(az ad user list --query "[?displayName=='$MEIDOBJECTNAME_USER_CLUSTERADMIN_DISPLAY_NAME'].id" -o tsv)
echo TENANTDOMAIN_K8SRBAC: $TENANTDOMAIN_K8SRBAC
echo MEIDOBJECTNAME_USER_CLUSTERADMIN: $MEIDOBJECTNAME_USER_CLUSTERADMIN
echo MEIDOBJECTID_USER_CLUSTERADMIN: $MEIDOBJECTID_USER_CLUSTERADMIN

# Add the cluster admin user(s) to the cluster admin security group.
echo "Add the cluster admin user(s) to the cluster admin security group."
az ad group member add -g $MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE --member-id $MEIDOBJECTID_USER_CLUSTERADMIN
echo "Added the cluster admin user, '$MEID' the cluster admin security group, '$MEIDOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE_DISPLAY_NAME'"

# Create a namespace reader group for your AKS cluster for '$MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE_DISPLAYNAME'
az ad group create --display-name 'cluster-ns-a0008-readers-bu0001a000800' --mail-nickname 'cluster-ns-a0008-readers-bu0001a000800' --description "Principals in this group are readers of namespace a0008 in the bu0001a000800 cluster."
echo "Namespace reader group created for '$MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE_DISPLAYNAME'"

# Set MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE
echo "Set MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE"
export MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE=$(az ad group list --query "[?displayName=='$MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE_DISPLAYNAME'].id" -o tsv)
echo MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE: $MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE

# Replace '<replace-with-a-microsoft-entra-group-object-id-for-this-cluster-role-binding>' in k8s/cluster-rbac-template.yaml
echo "Replace '<replace-with-a-microsoft-entra-group-object-id-for-this-cluster-role-binding>' in k8s/cluster-rbac-template.yaml with '$MEIDOBJECTID_USER_CLUSTERADMIN'"
sed "s/<replace-with-a-microsoft-entra-group-object-id-for-this-cluster-role-binding>/$MEIDOBJECTID_USER_CLUSTERADMIN/g" k8s/cluster-rbac-template.yaml > k8s/cluster-rbac.yaml
echo "Replaced '<replace-with-a-microsoft-entra-group-object-id-for-this-cluster-role-binding>' in k8s/cluster-rbac-template.yaml with '$MEIDOBJECTID_USER_CLUSTERADMIN' to k8s/cluster-rbac.yaml"

# Replace '<replace-with-a-microsoft-entra-group-object-id-for-this-namespace-role-binding>' in k8s/rbac-template.yaml
echo "Replace '<replace-with-a-microsoft-entra-group-object-id-for-this-namespace-role-binding>' in k8s/rbac-template.yaml with $MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE"
sed "s/<replace-with-a-microsoft-entra-group-object-id-for-this-namespace-role-binding>/$MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE/g" k8s/rbac-template.yaml > k8s/rbac.yaml
echo "Replaced '<replace-with-a-microsoft-entra-group-object-id-for-this-namespace-role-binding>' in k8s/rbac-template.yaml with $MEIDOBJECTID_GROUP_A0008_READER_AKS_BASELINE to k8s/rbac.yaml"


