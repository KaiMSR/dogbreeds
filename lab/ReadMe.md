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
- Have either:

  - Set up on DSVM, see [Setup on DVSM](SetUpAzureMLOnDSVM.md) for details
  - Set up on a development computer you provide, see [Setup on development system](SetUpOwnDevSystem.md)

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

## Open a command prompt on your system

Run the following commands to retrieve this repo.

```bash
# get the Azure DLI demo
mkdir ~/notebooks # error is okay on dsvm
cd ~/notebooks
git clone https://github.com/msraidli/dogbreeds
conda init --all
```

Close the shell window and open a new command prompt.

Next, update your system with the latest version of the CLI and the Azure Machine Learning services SDK:

```bash
cd ~/notebooks/dogbreeds/lab
bash updateaml.sh
```

NOTE: The script creates an Azure Machine Learning services environment in conda. Once you update the default 
environment, be sure to start from the azureml environment. This helps prevent overwriting a dependency in 
your own development environment.

## Set environment variables

Get the following information from your admin and copy and paste into the shell.

The information to paste into the shell will be something like the following:

```bash
export SUBSCRIPTION_ID="bede334e-e255-4bcb-89f1-995292e83222"
export RESOURCE_GROUP="msr-demo8-westeurope-test-rg"
export WORKSPACE="msrdemo8westeuropedevws"
export CLUSTER_NAME="k80-1gpu-wu-low"

export DATA_STORAGE_ACCOUNT="msrsamplewedatast"
export DATA_STORAGE_CONTAINER="breeds"
```

NOTE - The preceding text is an example. You need to get the actual data from your admin.

## Get started in your workspace

Start Jupyter Notebook using the following in the shell.

```bash
conda activate azureml
az login
export DATA_STORAGE_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n DATA_STORAGE_ACCOUNT --query [0].value | tr -d '"')
jupyter notebook
```

Click the folder in the default notebook and navigate to ~/notebooks/dogbreeds/lab/[dog-breed-lab-orientation.ipynb](dog-breed-lab-orientation.ipynb)

## Follow up steps

When you are ready to user your own data, copy your data into your storage account. See [CopyData](CopyData.md).

If forget the information the admin sent you about your workspace, see [Retrieve Workspace Info](RetrieveWorkspaceInfo.md).

## Special thanks

Daniel and the Azure CAT team.
And to Juan Lema for deep passion and careful review of this repo.

