# Set up your development system for Azure Machine Learning services

Use the following steps to set up the Machine Learning services on your development platform.

This set up helps insure that you can share data among your team, while at the same time, keeping data confidential.
In addition, the set up allows administrators to set restrictions on usage to keep your budget from going crazy.

## Prerequisites

You can use your own development system on Mac, Windows, or Linux.

## Set up development system

Your development system can be Windows or Linux.

To take advantage of GPUs and the latest containers using CUDA, you need to be using Linux as your development system.
That said, you can start developing your application on CPUs on Mac or Windows, then send your code to Azure Machine Learning services from your desktop.

If you are using your own development system, you will need:

1. Azure subscription
2. To start Bash or PowerShell as admin. Can be [Bash on Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
3. Install [Git](https://git-scm.com/downloads)
4. Install (or update) [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
5. Install [Conda](https://docs.anaconda.com/anaconda/install/) and its dependencies. Be sure [Conda is on the PATH](https://stackoverflow.com/questions/50906037/add-conda-to-my-environment-variables-or-path).
6. Install [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?toc=%2fazure%2fstorage%2fblobs%2ftoc.json)
7. Install [Azure Machine Learning CLI](https://docs.microsoft.com/en-us/python/api/overview/azure/ml/install?view=azure-ml-py)
8. [Optional] install [Docker](https://docs.docker.com/install/)

# Next steps

Continue the set up process in the [ReadMe](ReadMe.md).


