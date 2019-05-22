# Set the storage accouont and key vault name for your data
export DATA_STORAGE_ACCOUNT
read -p "Enter the name of the data storage account, such as 'msrsamplewedatast'" DATA_STORAGE_ACCOUNT
export DATA_STORAGE_CONTAINER="dogbreeds" 
read -p "Enter the name of the data storage container for your data, such as 'dogbreeds'" DATA_STORAGE_CONTAINER
read -p "Enter the name of the key vault that holds the key for your data, such as 'msrsamplewedatakv'" $DATA_KEYVAULT

# Set workspace information
export SUBSCRIPTION_ID
read -p "Enter your resource group, such as 'abf57110-9581-47e3-a15e-03754e3661ec'" SUBSCRIPTION_ID
export RESOURCEGROUP_NAME
read -p "Enter your resource group, such as 'msr-demo8-westeurope-test-rg'" RESOURCEGROUP_NAME
export WORKSPACE_NAME
read -p "Enter your workspace name, such as 'msrdemo8westeuropedevws'" WORKSPACE_NAME



## log in to Azure
az login

## log in using the browser
az account set --subscription $SUBSCRIPTION_ID
az account show

PATHIO="/subscriptions/710e04b9-9155-4f01-aa8e-52848f055ad2/resourcegroups/msr-demo8-westeurope-test-rg/providers/microsoft.keyvault/vaults/msrdemo8wetestkv"

WORKSPACE_STORAGE=az ml workspace show --resource-group $RESOURCE_GROUP --name $WORKSPACE_NAME --query storageAccount
export WORKSPACE_STORAGE_ACCOUNT=basename "$WORKSPACE_STORAGE"
WORKSPACE_KEYVAULT=az ml workspace show --resource-group $RESOURCE_GROUP --name $WORKSPACE_NAME  --query keyVaultName

export AML_COMPUTE_TARGET
read "Enter your compute target, such as 'p100-4gpus-ded-westeurope'" AML_COMPUTE_TARGET

# by convention the admin used the storage account as the name of the key stored key vault 
DATA_KEY=az keyvault secret show --name $DATA_STORAGE_ACCOUNT \
  --vault-name $DATA_KEYVAULT --query value

export DATA_STORAGE_KEY=$DATA_KEY

# by convention the admin used the storage account as the name of the key stored key vault 
WORKSPACE_KEY=az keyvault secret show --name WORKSPACE_STORAGE_ACCOUNT \
  --vault-name $WORKSPACE_KEYVAULT --query value

export WORKSPACE_STORAGE_KEY=$WORKSPACE_KEY

## COPY DATA TO AZURE STORAGE IF NEEDED

cd ~
jupyter notebook

# go to ~/msraidll/dogbreeds/team
