#! /bin/sh

az feature register --namespace "Microsoft.ContainerService" -n "EnableImageCleanerPreview"

# Keep running until all say "Registered." (This may take up to 20 minutes.)
az feature list -o table --query "[?name=='Microsoft.ContainerService/EnableImageCleanerPreview'].{Name:name,State:properties.state}"

# When all say "Registered" then re-register the AKS resource provider
az provider register --namespace Microsoft.ContainerService