# Copy your data to Azure storage account using Key Vault key

The administrator has set up the Dogbreeds data in a common repository that you team can access.

Your project will use a different set of data, which you copy into your Azure Storage account.

For small data sizes, you can: 

- [Copy data using the portal](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal)
- [Copy data using the Azure ML Python SDK into Datastore](https://docs.microsoft.com/en-us/python/api/azureml-core/azureml.data.azure_storage_datastore.abstractazurestoragedatastore?view=azure-ml-py#upload-src-dir--target-path-none--overwrite-false--show-progress-true-)

For large amounts of data, you will want to use [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10). 
The code in this article provides a way to copy data with AzCopy using keys that are stored key vault. 

The code samples in this article use the convention suggested to the [administrator](admin/Readme.md) of using the name of the storage account containing the storage account access key as the name of the key in Key Vault.

## Prerequisites

You will need the following prerequisites:

- Azure subscription
- Azure storage account
- [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?toc=%2fazure%2fstorage%2fblobs%2ftoc.json) installed

The following code assumes that the storage key has been stored into a Key Vault resource.

## Set environment variables

You should have already set environment variables 

### Using PowerShell

```powershell
$KEYVAULT_NAME = <the key vault name with the key to your data>
$env:AZURE_STORAGE_ACCOUNT = <the data storageaccount>
$env:AZURE_STORAGE_CONTAINER = <storage container/folder for your data>
```

### Using Bash

```bash
KEYVAULT_NAME=<the key vault name with the key to your data>
export AZURE_STORAGE_ACCOUNT=<data_account_name> 
export AZURE_STORAGE_CONTAINER=<storage container for your data>
```

## Copy data using PowerShell

Copy your data from `C:\myfolder` using PowerShell:

```powershell
$retrievedPassword = az keyvault secret show --vault-name $KEYVAULT_NAME \    
    --name $env:AZURE_STORAGE_ACCOUNT 
$env:AZURE_STORAGE_KEY = $retrievedPassword.SecretValueText 

cd 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy'
./AzCopy `
    /Source:C:\myfolder `
    /Dest:https://$storageAccountName.blob.core.windows.net/$env:AZURE_STORAGE_CONTAINER `
    /DestKey:$env:AZURE_STORAGE_KEY `
    /S
```

## Copy data using Bash

Copy your data from `/mnt/myfiles/` using Bash:

```bash
export AZURE_STORAGE_KEY=$(az storage account keys list -g $resourcegroup_name -n $data_lake_store_name --query [0].value | tr -d '"')

azcopy \
  --source /mnt/myfiles/ \ 
  --destination https://$storageAccountName.blob.core.windows.net/$AZURE_STORAGE_CONTAINER \ 
  --dest-key $AZURE_STORAGE_KEY \
  --recursive
```

## More information

For more information on using AzCopy, see [Transfer data with AzCopy v10](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?toc=%2fazure%2fstorage%2fblobs%2ftoc.json)
