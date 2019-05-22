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

If you have lost the information, see [How to retrieve your workspace information from the portal](RetrieveWorkspaceInfo.md)

## Next steps

Run the sample notebook.

When you are ready to user your own data, copy your data into your storage account. See [CopyData](CopyData.md).

## Special thanks

Daniel and the Azure CAT team.

