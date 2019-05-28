#!/bin/sh

## this script sets up the Azure Machine Learning service workspace using the inputs

echo "CREATING WORKSPACE, ASSIGNING ROLES"

## it tags the resource group and resources
## it also adds user and team

## script requires Azure CLI with the Azure ML extension to be installed

read -p  "Enter the subscription ID: " SUBSCRIPTION_ID
read -p  "Enter the department name (4 chars): " DEPARTMENT_NAME
DEPARTMENT_NAME=${DEPARTMENT_NAME:0:4}
read -p  "Enter the team name (10 chars): " TEAM_NAME
TEAM_NAME=${TEAM_NAME:0:10}
read -p  "Enter the location (such as westus2 or westeurope): " LOCATION
read -p  "Enter the location abbreviation (such as w2 or we) (2 chars): " LOCATION_ABBR
LOCATION_ABBR=${LOCATION_ABBR:0:2}
read -p  "Enter the enviornment, such as res dev pro (3 chars): " DEVENVIRONMENT
DEVENVIRONMENT=${DEVENVIRONMENT:0:3}
read -p  "Enter the team leader: " TEAM_LEAD
read -p  "Enter the team security group: " TEAM_SECURITY_GROUP
read -p "Create Azure Data Lake Store account (y/n): " ADLS

resourcegroup_name=$DEPARTMENT_NAME-$TEAM_NAME-$LOCATION-$DEVENVIRONMENT
resource_name=$DEPARTMENT_NAME$TEAM_NAME$LOCATION_ABBR$DEVENVIRONMENT
resource_name=${resource_name:0:19}

echo 'RESOURCE GROUP: '$resourcegroup_name 
echo 'resource_name: '$resource_name

read -p "Press 'y' to continue " CONTINUE_NOW
if [ $CONTINUE_NOW != 'y' ]
then
    exit 1
fi

echo "logging into Azure"
az login

echo "setting subscription to "$SUBSCRIPTION_ID
az account set --subscription $SUBSCRIPTION_ID

## create resource group
resource_exists=$(az group exists --name $resourcegroup_name)
if [ $resource_exists == 'false' ]
then
    echo "created: " $resourcegroup_name
    az group create --name $resourcegroup_name --location $LOCATION
	
else
	echo "resource group not created"
fi

az group update -n $resourcegroup_name --set tags.dept=$DEPARTMENT_NAME tags.team=$TEAM_NAME tags.owner=$TEAM_LEAD tags.expires=2019-06-30 tags.location=$LOCATION 

workspace_name=$resource_name"ws"
workspace_storage_account_name=$resource_name"work"
workspace_storage_account_name=${workspace_storage_account_name:0:23}

data_storage_account_name=$resource_name"data"
data_storage_account_name=${data_storage_account_name:0:23}

container_registry_name=$resource_name"cr"
container_registry_name=${container_registry_name:0:23}

key_vault_name=$resource_name"kv"
key_vault_name=${key_vault_name:0:23}


## create storage accounts
storage_name_available=$(az storage account check-name --name $workspace_storage_account_name | jq .nameAvailable)
if [ $storage_name_available == 'true' ]
then
    echo $workspace_storage_account_name" is available"
else
	echo $workspace_storage_account_name" is not available: perhaps shorten team name or make it more unique"
	exit 1
fi

storage_name_available=$(az storage account check-name --name $workspace_storage_account_name | jq .nameAvailable)
if [ $storage_name_available  == 'true' ]
then
    echo $data_storage_account_name" is available"
else
	cho $data_storage_account_name" is not available: shorten team name or make it more unique"
	exit 1
fi


## this storage account is for Azure ML results and logs

echo "creating storage account "$workspace_storage_account_name
az storage account create --name $workspace_storage_account_name \
                        --resource-group $resourcegroup_name \
                        --location $LOCATION \
                        --sku Standard_LRS \
                        --kind StorageV2 

workspace_storage_id=$(az storage account show -n $workspace_storage_account_name --query id | tr -d '"')
workspace_storage_key=$(az storage account keys list -g $resourcegroup_name -n $workspace_storage_account_name --query [0].value | tr -d '"')

## this storage account is for the user data

echo "creating storage account "$data_storage_account_name
az storage account create --name $data_storage_account_name \
                        --resource-group $resourcegroup_name \
                        --location $LOCATION \
                        --sku Standard_LRS \
                        --kind StorageV2 

data_storage_account_id=$(az storage account show -n $data_storage_account_name --query id | tr -d '"')
data_storage_account_key=$(az storage account keys list -g $resourcegroup_name -n $data_storage_account_name --query [0].value | tr -d '"')
az resource tag --name $data_storage_account_name --resource-group $resourcegroup_name --tags dept=$DEPARTMENT_NAME team=$TEAM_NAME owner=$TEAM_LEAD expires=2019-06-30 location=$LOCATION role=data --resource-type "Microsoft.Storage/storageAccounts"

## if Azure Data Lake Storage is required

ADLS="${ADLS,,}"
if [ $ADLS == 'y' ]
then
	data_lake_store_name=$resource_name"big"
	data_lake_store_name=${data_lake_store_name:0:23}
	echo "creating data lake account "$data_lake_store_name
	
	az storage account create --name $data_lake_store_name \
							--resource-group $resourcegroup_name \
							--location $LOCATION \
							--sku Standard_LRS \
							--kind StorageV2 \
							--hierarchical-namespace true

	data_lake_storage_account_id=$(az storage account show -n $data_lake_store_name --query id | tr -d '"')
	data_lake_storage_account_key=$(az storage account keys list -g $resourcegroup_name -n $data_lake_store_name --query [0].value | tr -d '"')
	az resource tag --name $data_lake_store_name --resource-group $resourcegroup_name --tags dept=$DEPARTMENT_NAME team=$TEAM_NAME owner=$TEAM_LEAD expires=2019-06-30 location=$LOCATION role=bigdata --resource-type "Microsoft.Storage/storageAccounts"
fi

## create key vault

echo "creating key vault "$key_vault_name
az keyvault create --name $key_vault_name --resource-group $resourcegroup_name --location $LOCATION

key_vault_id=$(az keyvault show --name $key_vault_name --resource-group $resourcegroup_name --query id | tr -d '"')

## put keys into key vault

az keyvault key create --vault-name $key_vault_name --name $data_storage_account_name --protection software
az keyvault secret set --name $data_storage_account_name --vault-name $key_vault_name --value $data_storage_account_key

az keyvault key create --vault-name $key_vault_name --name $workspace_storage_account_name --protection software
az keyvault secret set --name $workspace_storage_account_name --vault-name $key_vault_name --value $workspace_storage_key

## create container registry
echo "creating container registry "$container_registry_name
name_available=$(az acr check-name --name $container_registry_name --query nameAvailable)
if [ $name_available == 'true' ]
then
	echo "name available for container registry "$container_registry_name
	az acr create --name $container_registry_name --resource-group $resourcegroup_name --sku Basic --location $LOCATION --admin-enabled true
	container_registry_id=$(az acr show --name $container_registry_name --resource-group $resourcegroup_name --query id | tr -d '"')
	echo "container registry created: " $container_registry_name 
else
	echo "container registry not available: " $container_registry_name 
	exit 1
fi

## create workspace
echo "creating workspace "$workspace_name
az ml workspace create --workspace $workspace_name --resource-group $resourcegroup_name --location $LOCATION \
    --verbose --storage-account $workspace_storage_id \
    --keyvault $key_vault_id  \
    --container-registry $container_registry_id

## tag resources
workspace_json=$(az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name)
echo $workspace_json

echo "retrieving the providers"
workspace_provider=$(echo $workspace_json | jq .id | tr -d '"')
echo "using workspace provider id"$workspace_provider

storageAccount_provider=$(echo $workspace_json | jq .storageAccount | tr -d '"')
echo "using storage provider id"$storageAccount_provider

applicationInsights_provider=$(echo $workspace_json | jq .applicationInsights | tr -d '"')
echo "using appInsights provider id"$applicationInsights_provider

containerRegistry_provider=$(echo $workspace_json | jq .containerRegistry | tr -d '"')
echo "using workspace provider id"$containerRegistry_provider

keyVault_provider=$(echo $workspace_json | jq .keyVault | tr -d '"')
echo "using key vault provider id"$keyVault_provider

echo "tagging resources "
## tag resources for workspace as built
az resource tag --id $workspace_provider $storageAccount_provider $applicationInsights_provider $containerRegistry_provider $keyVault_provider --tags dept=$DEPARTMENT_NAME team=$TEAM_NAME owner=$TEAM_LEAD expires=2019-06-30 location=$LOCATION role=AML

##########
# SET ADMIN
##########

echo "setting role based access control"

if [ $TEAM_LEAD == "" ]
then
    echo "no team lead"
else 
	admin=$TEAM_LEAD"@microsoft.com"
	echo "adding team lead: "$admin

# if desired, grant owner permission for the team lead to the resource group
# az role assignment create --role 'Owner' --assignee $admin  --resource-group $resourcegroup_name

	az ml workspace share -w $workspace_name -g $resourcegroup_name --role "ML User" --user $admin

	az role assignment create --role 'Owner' --assignee $admin --scope $applicationInsights_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $storageAccount_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $keyVault_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $containerRegistry_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $data_storage_account_id

	if [ $ADLS == 'y' ]
	then
		az role assignment create --role 'Owner' --assignee $admin --scope $data_lake_storage_account_id
    fi
fi

##########
# ADD INDIVIDUAL USER
##########

if [[ -z $INDIDUAL_USER_LEAD ]]
then
	echo "no individual user to add"
else
	$user = $useralias + "@microsoft.com"
	echo "adding "$user" as contributor"

	# if desired, grant owner permission for the team lead to the resource group
	# az role assignment create --role 'Owner' --assignee $admin  --resource-group $resourcegroup_name

	az ml workspace share -w $workspace_name -g $resourcegroup_name --role "Ml User" --user $admin

	az role assignment create --role 'Contributor' --assignee $admin --scope $applicationInsights_provider
	az role assignment create --role 'Contributor' --assignee $admin --scope $storageAccount_provider
	az role assignment create --role 'Contributor' --assignee $admin --scope $keyVault_provider
	az role assignment create --role 'Contributor' --assignee $admin --scope $containerRegistry_provider
	az role assignment create --role 'Contributor' --assignee $admin --scope $data_storage_account_id
	if [ $ADLS == 'y' ]
	then
		az role assignment create --role 'Contributor' --assignee $admin --scope $data_lake_storage_account_id
    fi
fi

##########
# SET TEAM USING SECURITY GROUP
##########

if [[ -z $TEAM_SECURITY_GROUP ]]
then
	echo "no team to add"az
else
	echo "adding security group as contributors "$TEAM_SECURITY_GROUP
    az ad group show --group $TEAM_SECURITY_GROUP

    $group_id=$(az ad group show --group $TEAM_SECURITY_GROUP --query objectid)

    echo "adding security group "$group_id" to workspace "$workspace_name
    # az ml workspace share -w $workspace_name -g $resourcegroup_name --role "ML User" --user $group_id ## possibily fails

    az role assignment create --role 'ML User' ---assignee-object-id  $group_id  --scope  $workspace_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $applicationInsights_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $storageAccount_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $keyVault_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $containerRegistry_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $data_storage_account_id

	if [ $ADLS == 'y' ]
	then
		az role assignment create --role 'Contributor'--assignee-object-id  $group_id --scope $data_lake_storage_account_id
    fi
fi

echo "Welcome to Azure Machine Learning Services "$admin
echo "Here are the variables you need to get started: "
echo "export SUBSCRIPTION_ID=\""$SUBSCRIPTION_ID"\""
echo "export RESOURCE_GROUP=\""$resourcegroup_name"\""
echo "export WORKSPACE_NAME=\""$workspace_name"\""
echo "export WORKSPACE_STORAGE_ACCOUNT=\""$workspace_storage_account_name"\""
echo 
echo "Here are so additional resources for you"
echo "YOUR DATA STORAGE ACCOUNT: "$data_storage_account_name
echo "YOUR KEY VAULT: "$key_vault_name
if [ $ADLS == 'y' ]
then
    echo "YOUR DATA LAKE STORAGE ACCOUNT: "$data_lake_store_name
fi
echo
echo "done"
