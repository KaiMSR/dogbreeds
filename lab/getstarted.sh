# Set the storage accouont and key vault name for your data
export DATA_STORAGE_ACCOUNT="msrsamplewedatast"
export DATA_STORAGE_CONTAINER="dogbreeds" 
DATA_KEYVAULT_NAME="msrsamplewedatakv"

# Set workspace information
export SUBSCRIPTION_ID
read -p "Enter your resource group, such as 'abf57110-9581-47e3-a15e-03754e3661ec'" SUBSCRIPTION_ID
export RESOURCEGROUP_NAME
read -p "Enter your resource group, such as 'msr-demo8-westeurope-test-rg'" RESOURCEGROUP_NAME
export WORKSPACE_NAME
read -p "Enter your workspace name, such as 'msrdemo8westeuropedevws'" WORKSPACE_NAME
export WORKSPACE_STORAGE_ACCOUNT
read "Enter your workspace storage account name, such as 'msrdemo8wetestst'" WORKSPACE_STORAGE_ACCOUNT
read -p "Enter your workspace key vault name, such as 'msrdemo8wetestkv'" WORKSPACE_KEYVAULT

export AML_COMPUTE_TARGET
read "Enter your compute target, such as 'p100-4gpus-ded-westeurope'" AML_COMPUTE_TARGET

## log in to Azure
az login

## log in using the browser

az account set --subscription $SUBSCRIPTION_ID
az account show

# by convention the admin used the storage account as the name of the key stored key vault 
KEY=az keyvault secret show --name $DATA_STORAGE_ACCOUNT \
  --vault-name $DATA_KEYVAULT_NAME | \
python -c 'import sys, json; \ sys.stdout.write(json.load(sys.stdin)[0][\" value\"])')

export DATA_STORAGE_KEY=$KEY

# by convention the admin used the storage account as the name of the key stored key vault 
KEY=az keyvault secret show --name WORKSPACE_STORAGE_ACCOUNT \
  --vault-name $WORKSPACE_KEYVAULT | \
python -c 'import sys, json; \ sys.stdout.write(json.load(sys.stdin)[0][\" value\"])')

export WORKSPACE_STORAGE_KEY=$KEY

## COPY DATA TO AZURE STORAGE IF NEEDED

cd ~
jupyter notebook

# go to ~/msraidll/dogbreeds/team