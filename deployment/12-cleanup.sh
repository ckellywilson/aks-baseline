#! /bin/sh

# Delete resource groups
echo "Deleting resource groups"
for resourceGroup in $(az group list --query "[?starts_with(name, 'rg-')].name" -o tsv); do
    echo "Deleting resource group '$resourceGroup'"
    az group delete -n $resourceGroup --yes --no-wait
    echo "Deleted resource group '$resourceGroup'"
done

# Delete NetworkWatcherRG
echo "Deleting NetworkWatcherRG"
az group delete -n NetworkWatcherRG --yes --no-wait
echo "Deleted NetworkWatcherRG"

# Delete ad groups
echo "Deleting ad groups"
for adGroup in $(az ad group list --query "[?starts_with(displayName, 'cluster-')].displayName" -o tsv); do
    echo "Deleting ad group '$adGroup'"
    az ad group delete --group $adGroup
    echo "Deleted ad group '$adGroup'"
done

# Delete Users
echo "Deleting users"
for user in $(az ad user list --query "[?starts_with(displayName, 'cluster-')].displayName" -o tsv); do
    echo "Deleting user '$user'"
    az ad user delete --upn-or-object-id $user
    echo "Deleted user '$user'"
done




