# Welcome to Azure Machine Learning service in a lab environment

This document provides the steps to get started using Azure Machine Learning services.

In this documentation, see how the administrator has set up your workspace and how you can use the AML Compute Target.

This particular folder, use the Dog Breeds demo to set up how you can organize Azure Machine Learning services for teams of users

The document describes how to get started among two roles:

- For lab admins on how to set up Azure Machine Learning services workspace and compute clusters using PowerShell and Bash scripts
- For users (researchers and data scientists), how to get started using Azure Machine Learning services

The user getting started guide is based on [Danielsc's dogbreeds application in Azure ML](https://github.com/danielsc/dogbreeds/).

The admin folder shows how your administrator can set up your:

- Workspace
- The resources associated with the worskpace
- Shared data, such as the Dog Breeds data
- Role based access control to the workspace and clusters

## Prerequisites

Here are the prerequisites for users to get started.

- Understand fundamentals of [Azure Machine Learning Services](https://docs.microsoft.com/en-us/azure/machine-learning/service/), including workspaces, experiments, compute
- Install the following:

  - Azure CLI
  - Conda
  - AzCopy
  - Azure ML CLI

See [Setup](Setup.md) for details.

Your admin will have already:

- Copied the dogbreeds data to a Azure storage account in a container named `dogbreeds`
- Set up the key to the dogbreeds data stored in its own keyvault.

Your admin will provide you with:

  - Dogbreeds data storage account name and shall have granted you permissions to read the data
  - Dogbreeds storage account container name, `dogbreeds`
  - Key vault name the organization uses for the Dogbreeds demo data & granted you permissions to the key vault
  - Your subscription ID
  - Your resource group name 
  - Your workspace name
  - The name of the storage account associated with your workspace
  - The names of the AML Compute clusters you can use

## Get started in your workspace

Once you get the information, you can get started. Use the following steps to set environment variables, log into Azure.

### Linux

Set environment variables and start Jupyter in Linux:

```bash
export AZURE_STORAGE_ACCOUNT=<data_account_name> 
export AZURE_STORAGE_CONTAINER=<demo_data_storage_container> 
export RESOURCEGROUP_NAME=<resourcegroup_name>
export SUBSCRIPTION_ID=<subscription_id>
KEYVAULT_NAME=<demo_data_keyvault_name>

# set up the azure machine learning services environment
conda create -n azureml -y Python=3.6 ipywidgets nb_conda
conda activate azureml
pip install --upgrade azureml-sdk[notebooks,contrib] scikit-image tensorflow tensorboardX --user 
jupyter nbextension install --py --user azureml.widgets
jupyter nbextension enable azureml.widgets --user --py

# start up azure

az login

## log in using the browser

az account set –-subscription $SUBCRIPTION_ID
az account show

KEY=az keyvault secret show --name $AZURE_STORAGE_ACCOUNT \
  --vault-name $KEYVAULT_NAME | \
python -c 'import sys, json; \ sys.stdout.write(json.load(sys.stdin)[0][\" value\"])')

export AZURE_STORAGE_KEY=$KEY

## COPY DATA TO AZURE STORAGE IF NEEDED

cd ~
jupyter notebook
```

You can access the enironment varaible from inside the Notebook.

### Windows

Set environment variables and start Jupyter in Windows:

```powershell
$env:AZURE_STORAGE_ACCOUNT=<data_account_name> 
$env:AZURE_STORAGE_CONTAINER=<demo_data_storage_container> 
$env:RESOURCEGROUP_NAME=<resourcegroup_name>
$env:SUBSCRIPTION_ID=<subscription_id>
$KEYVAULT_NAME=<data_keyvault_name>

az login

## log in using the browser

az account set –-subscription $env:SUBCRIPTION_ID
az account show

$keys_in_json = az keyvault secret show `
  --name $storage_account_name `
  --vault-name $KEYVAULT_NAME 
$keys = $keys_in_json | ConvertFrom-Json
$key_value = $keys[0].value

$env:AZURE_STORAGE_KEY=$key_value

## COPY DATA TO AZURE STORAGE IF NEEDED

cd ~
jupyter notebook
```

You can access the enironment varaible from inside the Notebook.

## Next steps

Use Jupyter notebook. Navigate to the Jupyter notebook. 

Run the sample notebook.

When you are ready to user your own data, copy your data into your storage account. See Copydata.md

## Special thanks

Daniel and the Azure CAT team.

