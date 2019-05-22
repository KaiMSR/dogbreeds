# Set the storage accouont and key vault name for your data
$env:DATA_STORAGE_ACCOUNT=Read-Host "Enter your storage account for the experiment data, such as 'msrsamplewedatast'"
$env:DATA_STORAGE_CONTAINER=Read-Host "Enter your storage container for the experiment data, 'breeds'" 
$DATA_KEYVAULT_NAME=Read-Host "Enter your key vault with the key for the experiment data, 'msrsamplewedatakv'"

# Set workspace information
$env:SUBSCRIPTION_ID=Read-Host "Enter your resource group, such as 'abf57110-9581-47e3-a15e-03754e3661ec'"
$env:RESOURCEGROUP_NAME=Read-Host "Enter your resource group, such as 'msr-demo8-westeurope-dev-rg'"
$env:WORKSPACE_NAME=Read-Host "Enter your workspace name, such as 'msrdemo8westeuropedevws'"
$env:WORKSPACE_STORAGE_ACCOUNT=Read-Host "Enter your workspace storage account name, such as 'msrdemo8wedevst'"
$WORKSPACE_KEYVAULT=Read-Host "Enter your workspace key vault name, such as 'msrdemo8wedevkv'"

$env:AML_COMPUTETARGET=Read-Host "Enter your compute target, such as 'p100-4ded-we'"

## log in to Azure
az login

## log in using the browser

az account set --subscription $env:SUBSCRIPTION_ID
az account show

# by convention the admin used the storage account as the name of the key stored key vault 
$key_to_data_in_json = az keyvault secret show `
  --name $env:DATA_STORAGE_ACCOUNT `
  --vault-name $DATA_KEYVAULT_NAME 
$keys = $key_to_data_in_json | ConvertFrom-Json
$key_value = $keys[0].value

$env:DATA_STORAGE_KEY=$key_value

# by convention the admin used the storage account as the name of the key stored key vault 
$key_to_your_storage_in_json = az keyvault secret show `
    --name $env:WORKSPACE_STORAGE_ACCOUNT `
    --vault-name $WORKSPACE_KEYVAULT
$keys = $key_to_your_storage_in_json | ConvertFrom-Json
$key_value = $keys[0].value

$env:WORKSPACE_STORAGE_KEY=$key_value

## COPY DATA TO AZURE STORAGE IF NEEDED

cd ~
jupyter notebook

# go to ~/msraidll/dogbreeds/team
