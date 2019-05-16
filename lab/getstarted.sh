# Set the storage accouont and key vault name for your data
export DATA_STORAGE_ACCOUNT
read -p "Enter the name of the data storage account, such as 'msrsamplewedatast'" DATA_STORAGE_ACCOUNT
export DATA_STORAGE_CONTAINER="dogbreeds" 
read -p "Enter the name of the data storage container for your data, such as 'dogbreeds'" DATA_STORAGE_CONTAINER
read -p "Enter the name of the key vault that holds the key for your data, such as 'msrsamplewedatakv'" DATA_STORAGE_CONTAINER

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

# set up the azure machine learning services environment and update the packages
# conda create -n azureml -y Python=3.6 ipywidgets nb_conda
conda activate azureml
pip install --upgrade azureml-sdk[notebooks,contrib] scikit-image tensorflow tensorboardX --user 
jupyter nbextension install --py --user azureml.widgets
jupyter nbextension enable azureml.widgets --user --py


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
