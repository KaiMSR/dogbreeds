read -p  "Enter the subscription ID: " SUBSCRIPTION_ID
read -p  "Enter the department name: " DEPARTMENT_NAME
read -p  "Enter the team name: " TEAM_NAME
read -p  "Enter the location (such as westus2 or westeurope): " LOCATION
read -p  "Enter the location abbreviation (such as wu2 or we): " LOCATION_ABBR
read -p  "Enter the enviornment, such as res or dev or prod: " DEVENVIRONMENT
read -p  "Enter the team leader: " TEAM_LEAD
read -p  "Enter the team security group: " TEAM_SECURITY_GROUP

resourcegroup_name=$DEPARTMENT_NAME-$TEAM_NAME-$LOCATION-$DEVENVIRONMENT
resource_name=$DEPARTMENT_NAME$TEAM_NAME$LOCATION$DEVENVIRONMENT

echo $resourcegroup_name
echo resource_name

az login
az account set --subscription $SUBSCRIPTION_ID

## create resource group
resource_exists=$(az group exists --name $resourcegroup_name)
if [ $resource_exists == 'false' ]
then
    az group create --name $resourcegroup_name --location $LOCATION
	echo "created: " $resourcegroup_name
else
	echo "resource group not created"
fi

az group update -n $resourcegroup_name --set tags.dept=$DEPARTMENT_NAME tags.team=$TEAM_NAME tags.owner=$TEAM_LEAD tags.expires=2019-06-30 tags.location=$LOCATION 

workspace_name=$resource_name"ws"
workspace_storage_account_name=$resource_name"st"

data_storage_account_name=$DEPARTMENT_NAME$TEAM_NAME$LOCATION_ABBR"datast"
data_storage_account_name=${data_storage_account_name:0:23}
container_registry_name=$resource_name"cr"
key_vault_name=$resource_name"kv"

## create storage accounts

## this storage account is for Azure ML results and logs

az storage account create --name $workspace_storage_account_name \
                        --resource-group $resourcegroup_name \
                        --location $LOCATION \
                        --sku Standard_LRS \
                        --kind StorageV2 

workspace_storage_id=$(az storage account show -n $workspace_storage_account_name --query id | tr -d '"')
workspace_storage_key=$(az storage account keys list -g $resourcegroup_name -n $workspace_storage_account_name --query [0].value | tr -d '"')

## this storage account is for the user data

az storage account create --name $data_storage_account_name \
                        --resource-group $resourcegroup_name \
                        --location $LOCATION \
                        --sku Standard_LRS \
                        --kind StorageV2 

data_storage_account_id=$(az storage account show -n $data_storage_account_name --query id | tr -d '"')
data_storage_account_key=$(az storage account keys list -g $resourcegroup_name -n $data_storage_account_name --query [0].value | tr -d '"')
az resource tag --name $data_storage_account_name --resource-group $resourcegroup_name --tags dept=$DEPARTMENT_NAME team=$TEAM_NAME owner=$TEAM_LEAD expires=2019-06-30 location=$LOCATION role=data --resource-type "Microsoft.Storage/storageAccounts"

## create key vault

az keyvault create --name $key_vault_name --resource-group $resourcegroup_name --location $LOCATION

key_vault_id=$(az keyvault show --name $key_vault_name --resource-group $resourcegroup_name --query id | tr -d '"')

## put keys into key vault

az keyvault key create --vault-name $key_vault_name --name $data_storage_account_name --protection software
az keyvault secret set --name $data_storage_account_name --vault-name $key_vault_name --value $data_storage_account_key

az keyvault key create --vault-name $key_vault_name --name $workspace_storage_account_name --protection software
az keyvault secret set --name $workspace_storage_account_name --vault-name $key_vault_name --value $workspace_storage_key

## create container registry

name_available=$(az acr check-name --name $container_registry_name --query nameAvailable)
if [ $name_available == 'true' ]
then
	az acr create --name $container_registry_name --resource-group $resourcegroup_name --sku Basic --location $LOCATION --admin-enabled true
	container_registry_id=$(az acr show --name $container_registry_name --resource-group $resourcegroup_name --query id | tr -d '"')
	echo "container registry created: " $container_registry_name 
else
	echo "container registry not available: " $container_registry_name 
fi

## create workspace

az ml workspace create --workspace $workspace_name --resource-group $resourcegroup_name --location $LOCATION \
    --verbose --storage-account $workspace_storage_id \
    --keyvault $key_vault_id  \
    --container-registry $container_registry_id

## tag resources
# az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name 

workspace_provider=$(az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name --query id | tr -d '"')
storageAccount_provider=$(az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name --query storageAccount | tr -d '"')
applicationInsights_provider=$(az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name --query applicationInsights | tr -d '"')
containerRegistry_provider=$(az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name --query containerRegistry | tr -d '"')
keyVault_provider=$(az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name --query keyVault | tr -d '"')

## tag resources for workspace as built
az resource tag --id $workspace_provider $storageAccount_provider $applicationInsights_provider $containerRegistry_provider $keyVault_provider --tags dept=$DEPARTMENT_NAME team=$TEAM_NAME owner=$TEAM_LEAD expires=2019-06-30 location=$LOCATION role=AML

##########
# SET ADMIN
##########

if [ $TEAM_LEAD == "" ]
then
    echo "no team lead"
else 
	admin=$TEAM_LEAD"@microsoft.com"
	echo "adding team lead: " $admin

# if desired, grant owner permission for the team lead to the resource group
# az role assignment create --role 'Owner' --assignee $admin  --resource-group $resourcegroup_name

	az ml workspace share -w $workspace_name -g $resourcegroup_name --role "ML User" --user $admin

	az role assignment create --role 'Owner' --assignee $admin --scope $applicationInsights_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $storageAccount_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $keyVault_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $containerRegistry_provider
	az role assignment create --role 'Owner' --assignee $admin --scope $data_storage_account_id
fi

##########
# ADD INDIVIDUAL USER
##########

# if [[ -z $INDIDUAL_USER_LEAD ]]
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
fi

##########
# SET TEAM USING SECURITY GROUP
##########

if[ $TEAM_SECURITY_GROUP != "" ]
then
    az ad group show --group $env:TEAM_SECURITY_GROUP

    $group_json = az ad group show --group $env:TEAM_SECURITY_GROUP

    $group_object = $group_json | ConvertFrom-Json
    $group_id = $group_object.objectid
    $group_id

    echo adding security group to workspace $workspace_name
    # az ml workspace share -w $workspace_name -g $resourcegroup_name --role "ML User" --user $group_id ## possibily fails

    az role assignment create --role 'ML User' ---assignee-object-id  $group_id  --scope  $workspace_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $applicationInsights_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $storageAccount_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $keyVault_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $containerRegistry_provider
	az role assignment create --role 'Contributor' --assignee-object-id  $group_id --scope $data_storage_account_id

fi

echo "Welcome to Azure Machine Learning Services "$admin
echo "Here are the variables you need to get started: "
echo "SUBSCRIPTION_ID: "$SUBSCRIPTION_ID
echo "RESOURCE GROUP: "$resourcegroup_name
echo "WORKSPACE NAME: "$workspace_name
echo "STORAGE ACCOUNT FOR AML OUTPUT: "$workspace_storage_account_name
echo "YOUR DATA STORAGE ACCOUNT: "$data_storage_account_name
echo "YOUR KEY VAULT: "$key_vault_name