# Welcome to Azure Machine Learning service in a lab environment

This document provides steps to get started using Azure Machine Learning services:

1. Set up the environment variables
2. Run the notebook that will run a sample on Azure Machine Learning services

For:

- Administrators (in the [Admin/ReadMe](admin/ReadMe.md))
- Researchers (in this ReadMe)

This document shows how to use information provided by your administrator to get started in a sample project, DogBreeds.
In fact, this guide is based on [Danielsc's dogbreeds application in Azure ML](https://github.com/danielsc/dogbreeds/).

## Prerequisites

Here are the prerequisites for users to get started.

- Understand fundamentals of [Azure Machine Learning Services](https://docs.microsoft.com/en-us/azure/machine-learning/service/), including workspaces, experiments, compute
- Have either:

  - Set up on DSVM, see [Setup on DVSM](SetUpAzureMLOnDSVM.md).
  - Set up on a development computer you provide, see [Setup on development system](SetUpOwnDevSystem.md).

Your admin will have already:

- Copied the dogbreeds data to a Azure storage account in a container named `dogbreeds`
- Set up the key to the dogbreeds data stored in its own keyvault.

Your admin will provide you with:

  - Dogbreeds data storage account name and shall have granted you permissions to read the data
  - Dogbreeds storage account container name, `dogbreeds`
  - Key vault name the organization uses for the Dogbreeds demo data & granted you permissions to the key vault
  - Your subscription ID
  - Your resource group name of your workspace and of for the data
  - Your workspace name
  - The name of the storage account associated with your workspace
  - The name of the storage account set up for your data
  - The names of the AML Compute clusters you can use

Open a command prompt on your system and then:

1. Retrieve this repo
2. Update the CLI
3. Update Azure ML CLI and Azure ML for Pythton SDK
4. Set environment variables with your workspace and database settings
5. Start Azure and run your experiment in workspace using Jupyter Notebook
6. Run your experiment

## 1. Retrieve this repo

Run the following commands to retrieve this repo.

```bash
# get the Azure DLI demo
mkdir ~/notebooks # error is okay on dsvm
cd ~/notebooks
# git clone https://github.com/msraidli/dogbreeds
git clone --single-branch --branch labs https://github.com/msraidli/dogbreeds/tree/labs
conda init --all
```

Close the shell window and open a new command prompt.

## 2. Update the CLI

Next, update your system with the latest version of the CLI and the Azure Machine Learning services SDK.
User the following script in Bash or in PowerShell.

#### Update the Azure CLI in Bash on Linux or Bash on Windows

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 
```

#### Update the Azure CLI in PowerShell

Update the [Azure CLI on Windows](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest)

## 3. Update Azure ML CLI and Azure ML for Pythton SDK

The following code works in both PowerShell and Bash.

```
az extension remove -n azure-cli-ml
az extension add -n azure-cli-ml

conda create -n azureml -y Python=3.6 ipywidgets nb_conda

conda activate azureml
pip install --upgrade azureml-sdk[notebooks,contrib] scikit-image tensorflow tensorboardX azure-cli-core --user 
jupyter nbextension install --py --user azureml.widgets
jupyter nbextension enable azureml.widgets --user --py
```

NOTE: The script creates an Azure Machine Learning services environment in conda. Once you update the default 
environment, be sure to start from the azureml environment. This helps prevent overwriting a dependency in 
your own development environment.

## 4. Set environment variables with your workspace and database settings

Get the following information from your admin and copy and paste into the shell.

The information to paste into the shell will be something like the following:

#### In Bash

Replace this with the environment that your admin provides for Linux.

```bash
export SUBSCRIPTION_ID="bede334e-e255-4bcb-89f1-995292e83222"
export RESOURCE_GROUP="msr-demo8-westeurope-dev"
export WORKSPACE_NAME="msrdemo8westeuropedevws"
export CLUSTER_NAME="k80-1gpu-wu-low"

export DATA_RESOURCE_GROUP="msr-sample-westeurope-data-rg"
export DATA_STORAGE_ACCOUNT="msrsamplewedatast"
export DATA_STORAGE_CONTAINER="breeds"
```

#### In PowerShell

Replace this with the environment your admin providees for Windows.

```powershell
$env:SUBSCRIPTION_ID="710e04b9-9155-4f01-aa8e-52848f055ad2"
$env:RESOURCE_GROUP=msr-demo8-westeurope-dev"
$env:WORKSPACE_NAME="msrdemo8westeuropedevws"
$env:CLUSTER_NAME="k80-1gpu-wu-low"
	 
$env:DATA_RESOURCE_GROUP="msr-sample-westeurope-data-rg" 
$env:DATA_STORAGE_ACCOUNT="msrsamplewedatast"
$env:DATA_STORAGE_CONTAINER="dogbreeds"
```

NOTE - The preceding text is an example. You need to get the actual data from your admin.

## 5. Start Azure and run your experiment in workspace using Jupyter Notebook

Copy and paste the script into the shell. 

#### In Bash

```bash
conda activate azureml
az login
az account set --subscription $SUBSCRIPTION_ID
export DATA_STORAGE_KEY=$(az storage account keys list -g "$DATA_RESOURCE_GROUP" -n $DATA_STORAGE_ACCOUNT --query [0].value | tr -d '"')

cd ~/notebooks/dogbreeds/lab
jupyter notebook
```

NOTE - If you get `validation error: Parameter must conform to the following pattern: '^[-\\w\\._\\(\\)]+$'.`
You probably pasted a space in the environment variable.

#### In PowerShell

```bash
conda activate azureml
az login
az account set --subscription $env:SUBSCRIPTION_ID
$DATA_STORAGE_KEY=$(az storage account keys list -g $env:DATA_RESOURCE_GROUP -n $env:DATA_STORAGE_ACCOUNT --query [0].value)
$env:DATA_STORAGE_KEY = $env:DATA_STORAGE_KEY -replace '"', ""

cd ~/notebooks/dogbreeds/lab
jupyter notebook
```

## 6. Run your experiment

Start [dog-breed-lab-orientation.ipynb](dog-breed-lab-orientation.ipynb) to run your run on AML Compute cluster.

## Next steps

The Dogbreeds notebooks (in `~/notebooks/dogbreeds`) is similar and demonstrates more features of Azure Machine Learning service, such as:

- Distributed processing
- Hyperparameter sweepts
- Pipelines 
- Inferencing
- Automated machine learning (AutoML)

## Follow up steps

When you are ready to use your own data, copy your data into your data storage account. See [CopyData](CopyData.md).

If forget the information the admin sent you about your workspace, see [Retrieve Workspace Info](RetrieveWorkspaceInfo.md).

## Special thanks

Daniel and the Azure CAT team.
And to Juan Lema and Andy Lathrop for deep passion and careful review of this repo.

