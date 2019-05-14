<#
.SYNOPSIS 
Provisions a resource group, Azure ML workspace and associated resources
 
.DESCRIPTION
Provisions a resource group, Azure ML workspace and associated resources.
Sets tags for the resources. Sets permissions for team lead.
Asks for subscription ID, dept name, team name, team lead alias. 

#>

cd ~
az login

#######

az account show
az account list-locations

#######

$env:SUBSCRIPTION_ID = Read-Host -Prompt "Enter the subscription ID"
$env:DEPARTMENT_NAME = Read-Host -Prompt "Enter the department name"
$env:TEAM_NAME =       Read-Host -Prompt "Enter the team name"
$env:LOCATION =        Read-Host -Prompt "Enter the location (such as westus2 or westeurope)"
$env:LOCATION_ABBR =   Read-Host -Prompt "Enter the location (such as wu2 or we)"
$env:DEVENVIRONMENT =  Read-Host -Prompt "Enter the enviornment, such as res or dev or prod"
$env:TEAM_LEAD =       Read-Host -Prompt "Enter the team leader"
$env:TEAM_SECURITY_GROUP =       Read-Host -Prompt "Enter the team security group"

$env:DEPARTMENT_NAME = $env:DEPARTMENT_NAME.ToLower()
$env:TEAM_NAME =       $env:TEAM_NAME.ToLower()
$env:LOCATION =        $env:LOCATION.ToLower()
$env:DEVENVIRONMENT =  $env:DEVENVIRONMENT.ToLower()
$env:TEAM_LEAD =       $env:TEAM_LEAD.ToLower()
$env:TEAM_SECURITY_GROUP = $env:TEAM_SECURITY_GROUP.ToLower()

az account set --subscription $env:SUBSCRIPTION_ID
az account show

#######
# GET AND SET NAMES
#######

$resourcegroup_name = $env:DEPARTMENT_NAME + '-' + $env:TEAM_NAME + '-' + $env:LOCATION + '-' + $env:DEVENVIRONMENT + '-rg'
$resourcegroup_name = $resourcegroup_name.Substring(0,[System.Math]::Min(90, $resourcegroup_name.Length))
$resourcegroup_name

$resource_name = $env:DEPARTMENT_NAME + $env:TEAM_NAME + $env:LOCATION_ABBR + $env:DEVENVIRONMENT
$resource_name = $resource_name.ToLower()
$resource_name

$workspace_name = $env:DEPARTMENT_NAME + $env:TEAM_NAME + $env:LOCATION + $env:DEVENVIRONMENT + 'ws'
$workspace_name = $workspace_name.ToLower().Substring(0, [System.Math]::Min(33, $workspace_name.Length))
$workspace_name

$storage_account_name = $resource_name.Substring(0,[System.Math]::Min(22, $resource_name.Length))
$storage_account_name =  $storage_account_name + "st"
# echo $resource_name  $storage_account_name

$ACR_NAME = $resource_name + "cr"
$AKV_NAME = $resource_name + "kv"

#### TEST NAMES

az group exists --name $resourcegroup_name
# returns false
$storage_account_name
az storage account check-name --name $storage_account_name
# should returns "nameAvailable": true
az acr check-name --name $ACR_NAME
# returns "nameAvailable": true


#######
# SET RESOURCE GROUP
#######

az group create --location $env:LOCATION --resource-group $resourcegroup_name
az group update -n $resourcegroup_name --set tags.dept=$env:DEPARTMENT_NAME tags.team=$env:TEAM_NAME tags.owner=$env:TEAM_LEAD tags.expires=2019-06-30 tags.location=$env:LOCATION 

az group show -n $resourcegroup_name --query tags -o json | convertfrom-json
# shows resource group that was created

#########
# SET STORAGE ACCOUNT
#########

az storage account create --name $storage_account_name `
                        --resource-group $resourcegroup_name `
                        --location $env:LOCATION `
                        --sku  Standard_LRS `
                        --kind StorageV2 

az resource tag  --name $storage_account_name --resource-group $resourcegroup_name --tags dept=$env:DEPARTMENT_NAME team=$env:TEAM_NAME owner=$env:TEAM_LEAD expires=2019-06-30 location=$env:LOCATION --resource-type "Microsoft.Storage/storageAccounts"
              
$storage_account_json = az storage account show -n $storage_account_name 

$storage_account_object = $storage_account_json | ConvertFrom-Json
$storage_account_id = $storage_account_object.id
$storage_account_id

$storage_account_json = az storage account show -n $storage_account_name --query [].id

#################
# SET KEYVAULT
#################

az keyvault create --name $AKV_NAME --resource-group $resourcegroup_name --location $env:LOCATION `
                        --tags dept=$env:DEPARTMENT_NAME team=$env:TEAM_NAME owner=$env:TEAM_LEAD expires=2019-06-30 location=$env:LOCATION

$keyvault_json = az keyvault show --name $AKV_NAME
$keyvault_object = $keyvault_json | ConvertFrom-Json 
$keyvault_id = $keyvault_object.id
$keyvault_id

# get storage account key

$keys_in_json = az storage account keys list -g $resourcegroup_name -n $storage_account_name
$keys = $keys_in_json | ConvertFrom-Json
$key_value = $keys[0].value

az keyvault key create --vault-name $AKV_NAME --name $storage_account_name --protection software `
                        --tags dept=$env:DEPARTMENT_NAME team=$env:TEAM_NAME owner=$env:TEAM_LEAD expires=2019-06-30 location=$env:LOCATION storageaccount=$storage_account_name

az keyvault secret set --name $storage_account_name `
                       --vault-name $AKV_NAME `
                       --value $key_value 

# optional step for debugging to be sure you got the right value
az keyvault secret show --name $storage_account_name --vault-name $AKV_NAME

# az provider list --query "[].{Provider:namespace, Status:registrationState}" --out table 

###########
# SET CONTAINER REGISTRY
###########

$acr_json = az acr create --name $ACR_NAME --resource-group $resourcegroup_name `
     --sku Basic --location $env:LOCATION --admin-enabled true

$acr_object = $acr_json | ConvertFrom-Json
$acr_id = $acr_object.id
$acr_id

## NOTE Containter registry has Admin permissions enabled by default -- which is required by Azure ML which creates and pulls containers.

###########
# CREATE WORKSPACE
###########

az ml workspace create --workspace $workspace_name --resource-group $resourcegroup_name --location $env:LOCATION `
    --verbose --storage-account $storage_account_id `
    --keyvault $keyvault_id  `
    --container-registry $acr_id

####

az resource tag  --name $workspace_name --resource-group $resourcegroup_name `
    --tags dept=$env:DEPARTMENT_NAME team=$env:TEAM_NAME owner=$env:TEAM_LEAD expires=2019-06-30 location=$env:LOCATION `
    --resource-type "Microsoft.MachineLearningServices/workspaces"

$workspace_json  = az ml workspace show --workspace-name $workspace_name --resource-group $resourcegroup_name

$workspace_object = $workspace_json | ConvertFrom-Json
$workspace_id = $workspace_object.id
$workspace_id

$applicationInsights_id = $workspace_object.applicationInsights
$applicationInsights_id

##########
# SET ADMIN
##########

$admin = $env:TEAM_LEAD + "@microsoft.com"
$admin

# if desired, grant owner permission for the team lead to the resource group
# az role assignment create --role 'Owner' --assignee $admin  --resource-group $resourcegroup_name

az ml workspace share -w $workspace_name -g $resourcegroup_name --role "Data Scientist" --user $admin

az role assignment create --role 'Owner' --assignee $admin `
    --scope  $workspace_object.applicationInsights
az role assignment create --role 'Owner' --assignee $admin `
    --scope $workspace_object.storageAccount
az role assignment create --role 'Owner' --assignee $admin `
    --scope $workspace_object.keyVault
az role assignment create --role 'Owner' --assignee $admin `
   --scope $workspace_object.containerRegistry

##########
# ADD INDIVIDUAL USER
##########

$user = $useralias + "@contoso.com"
$user

# if desired, grant owner permission for the team lead to the resource group
# az role assignment create --role 'Owner' --assignee $admin  --resource-group $resourcegroup_name

az ml workspace share -w $workspace_name -g $resourcegroup_name --role "Data Scientistr" --user $admin

az role assignment create --role 'Contributor' --assignee $admin `
    --scope  $workspace_object.applicationInsights
az role assignment create --role 'Contributor' --assignee $admin `
    --scope $workspace_object.storageAccount
az role assignment create --role 'Contributor' --assignee $admin `
    --scope $workspace_object.keyVault
az role assignment create --role 'Contributor' --assignee $admin `
   --scope $workspace_object.containerRegistry

##########
# SET TEAM USING SECURITY GROUP
##########

if($env:TEAM_SECURITY_GROUP -ne "" -and $env:TEAM_SECURITY_GROUP -ne $null) {
    az ad group show --group $env:TEAM_SECURITY_GROUP

    $group_json = az ad group show --group $env:TEAM_SECURITY_GROUP

    $group_object = $group_json | ConvertFrom-Json
    $group_id = $group_object.objectid
    $group_id

    echo adding security group to workspace $workspace_name
    az ml workspace share -w $workspace_name -g $resourcegroup_name `
        --role "Data Scientist" --user $group_id ## possibily fails

    az role assignment create --role 'Data Scientist' ---assignee-object-id  $group_id `
        --scope  $workspace_object.id
    az role assignment create --role 'Contributor' ---assignee-object-id  $group_id `
        --scope  $workspace_object.applicationInsights
    az role assignment create --role 'Contributor' ---assignee-object-id  $group_id `
        --scope $workspace_object.storageAccount
    az role assignment create --role 'Contributor' ---assignee-object-id  $group_id `
        --scope $workspace_object.keyVault
    az role assignment create --role 'Contributor' ---assignee-object-id  $group_id `
       --scope $workspace_object.containerRegistry
}