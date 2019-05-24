# Admin guide to setting up Azure Machine Learning services for labs

This document provides steps for administrators of Azure ML around governance. 
The guidance provides concrete ways to:

- Provide appropriate access to team leads and users based on role based access control.
- Tag resources for future reporting requirements, queries, and usage monitoring at a team level.
- Restrict compute so that users have access, but cannot over spend.
- Secure resources by default using role based access control and access to keys.
- Show users how to securely access data and keep secrets out of their code.
- Organize access to resources based on teams and security groups that are already part of your organization.
- Provide a naming convention so you can find resources for each team.
- Set up compute for users to debug compute.
- Provide access to data shared across lab members.

One of the key goals is to restrict teams and users from create compute targets as a cost control measure.

## Set up the Azure CLI on

To get the Azure CLI up and running.

1. Install the WSFL. [Install the Azure CLI](https://docs.microsoft.com/en-us/azure/xplat-cli-install)
2. Open Bash as an administrator.
3. Install Azure CLI using `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`. You will need the admin password for sudo.
5. [If necessary] Remove current version of the Azure Machine Learning service CLI: `az extension remove -n azure-cli-ml`
4. Install Azure Machine Learning service CLI: `az extension add -n azure-cli-ml`

## Inputs

The workspace creation scripts ask the admin for the following data to set up the workspace:

- Department name
- Team name
- Location
- Team lead alias
- Security group assigned to the team
- Subscription ID

The compute target creation scripts needs:

- Number of nodes
- Priority (lowpriority or dedicated)
- Gpu type (such as K80 or P100 or CPU)
- Number of GPUs per node

## Code summary

There are several scripts for you to use.

- Set up the workspaces using the [Azure Resource Manager template to create a workspace for Azure Machine Learning service](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-create-workspace-template#use-azure-cli)
- Set up the compute

### Set up workspaces

The scripts provides:

- A prescrpitive naming convention for resoruce group, workspace, and its related resources.
- A prescriptive way to set up role based access control for the resource group and included resources.
- A prescriptive way to tag resources.

In order to make getting started as turn-key as possible, the script provides:

- Setting up the storage account keys into the user key vault.

### Set up compute resources

The script provide for a naming convention for users to see the type of compute clusters to use.
Sets limits to scale down cluster to zero when no longer needed
Set up limits on the maximun number of compute, number of seconds to idle so your users can debug
Username and password for users to SSH into the AML Cluster for debugging

## What information you provide your users

After you have set up your compute environment, provide your users with following information:

  - Dogbreeds data storage account name
  - Dogbreeds storage account container name, `dogbreeds`
  - Key vault name of the key vault for the Dogbreeds demo data
  - Your subscription ID
  - Your resource group name 
  - Your workspace name
  - The names of the AML Compute clusters your user can use

### Admin set up code

In the admin folder scripts show how to set up the Dog Breeds application.
The scripts are meant to be run in sections and for the admin to inspect each section.

Sections are marked  `#########`.

### Set up workspace and related resources

The [addworkspace.ps1](addworkspace.ps1) script provides for creating the resource group, creating resources for:

   - Storage account
   - Container registry
   - Application insights
   - Key vault
   - Azure Machine Learning workspace
   
Resources are tagged with team name, team lead, and expiration date.
Permissions are assigned at the resource level using Azure Active Directory identities:

|     | Admin | Team lead | User |
| --- | ----- | --------- | ---- |
| Resource group | Owner | [none] | [none] |
| Workspace | Inherited Owner | Data Scientist | Data Scientist |
| Storage account | Inherited Owner | Owner | Contributor |
| Container registry | Inherited Owner | Owner | Contributor |
| Key Vault | Inherited Owner | Owner | Contributor |
| App Insights  | Inherited Owner | Owner | Contributor |

The [Data Scientist](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-assign-roles) role is a currently a custom role. 

### Set up compute clusters

The other [New-AmlLabCompute.ps1](New-AmlLabCompute.ps1) script provides for creating the compute target.

The script asks for the compute target information:

- "Enter the maximum number of nodes"
- "Enter the priority, either lowpriority or dedicated"
- "Enter GPU type, such as K80, P100 or CPU"
- "Enter number of GPUs, 1, 2 or 4"

The compute target receives the name for users to understand the nature of compute:

- Type of GPU used in compute
- Number of GPUs in node
- Priority of the node, lowpriority as "low" or dedicated as "ded"
- Short abbreviation for the location

For example, `p100-1ded-we`.








