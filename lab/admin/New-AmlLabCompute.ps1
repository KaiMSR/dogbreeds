<#
.SYNOPSIS 
Sets compute in an Azure ML workspace
 
.DESCRIPTION
Provisions a resource group, Azure ML workspace and associated resources.
Sets tags for the resources. Sets permissions for team lead.
Asks for subscription ID, dept name, team name, team lead alias. 
#>

########
# SET Up ENVIRONMENT
########

$env:SUBSCRIPTION_ID = Read-Host -Prompt "Enter the subscription id"
$env:DEPARTMENT_NAME = Read-Host -Prompt "Enter the department name"
$env:TEAM_NAME =       Read-Host -Prompt "Enter the team name"
$env:LOCATION =        Read-Host -Prompt "Enter the location (such as westus2 or westeurope)"
$env:LOCATION_ABBR =   Read-Host -Prompt "Enter an abbreviation for the location (such as wu2 or we)"
$env:TEAM_LEAD =       Read-Host -Prompt "Enter the team leader"
       
az account set --subscription $env:SUBSCRIPTION_ID
az account show

$resourcegroup_name = $env:DEPARTMENT_NAME + '-' + $env:TEAM_NAME + '-' + $env:LOCATION + '-' + $env:DEVENVIRONMENT + '-rg'
$resourcegroup_name = $resourcegroup_name.Substring(0,[System.Math]::Min(90, $resourcegroup_name.Length))
$resourcegroup_name

$resource_name = $env:DEPARTMENT_NAME + $env:TEAM_NAME + $env:LOCATION_ABBR + $env:DEVENVIRONMENT
$resource_name = $resource_name.ToLower()
$resource_name

$workspace_name = $env:DEPARTMENT_NAME + $env:TEAM_NAME + $env:LOCATION + $env:DEVENVIRONMENT + 'ws'
$workspace_name = $workspace_name.ToLower().Substring(0, [System.Math]::Min(33, $workspace_name.Length))
$workspace_name


###########
# Set AMLComputeTarget
###########

echo workspacename=$workspace_name
echo resourcegroupname=$resourcegroup_name
echo subscriptionID=$env:SUBSCRIPTION_ID
echo location=$env:LOCATION

$nodes =          Read-Host -Prompt "Enter the maximum number of nodes"
$priority =       Read-Host -Prompt "Enter the priority, either lowpriority or dedicated"
$gpu_type =       Read-Host -Prompt "Enter GPU type, such as K80, P100 or CPU"
$num_gpu =        Read-Host -Prompt "Enter number of GPUs, 1, 2 or 4"

$priority_name = $priority.Substring(0,3)
$gpu_type = $gpu_type.ToLower()

$vm_size = "STANDARD_"

If($gpu_type -eq "k80") {
    if($num_gpu -eq 1) {
        $vm_size = $vm_size + "NC6"
    }
    if($num_gpu -eq 2) {
        $vm_size = $vm_size + "NC12"
    }
    if($num_gpu -eq 4) {
        $vm_size = $vm_size + "NC24"
    }
}

If($gpu_type -eq "p100") {
    if($num_gpu -eq 1) {
        $vm_size = $vm_size + "NC6s_v2"
    }
    if($num_gpu -eq 2) {
        $vm_size = $vm_size + "NC12s_v2"
    }
    if($num_gpu -eq 4) {
        $vm_size = $vm_size + "NC24s_v2"
    }
}

$computetarget_name = ""

$computetarget_name = $gpu_type + '-' + $num_gpu + $priority.Substring(0,3) + "-" + $env:LOCATION_ABBR

$computetarget_name = $computetarget_name.Substring(0,[System.Math]::Min(16, $computetarget_name.Length))

echo computetarget_name=$computetarget_name
echo max_nodes=$nodes
echo vm_size=$vm_size
echo priority=$priority
echo resourcegroup_name=$resourcegroup_name
echo workspace_name=$workspace_name
echo admin=$env:TEAM_LEAD

az ml computetarget create amlcompute --name $computetarget_name `
    --max-nodes $nodes --vm-size $vm_size `
    --workspace-name $workspace_name --idle-seconds-before-scaledown 1800 `
    --vm-priority $priority --resource-group $resourcegroup_name -v `
    --admin-username $env:TEAM_LEAD --admin-user-password $workspace_name

az ml computetarget show --name $computetarget_name `
    --workspace-name $workspace_name --resource-group $resourcegroup_name -v

$tag = ($vm_size + "_" + $priority + "=" + $nodes).ToString()
az resource update --resource-group $resourcegroup_name --name $workspace_name `
    --resource-type "Microsoft.MachineLearningServices/workspaces" --set tags.$tag

az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name

echo resourcegroup_name=$resourcegroup_name
echo workspace_name=$workspace_name
echo subscription_id=$env:SUBSCRIPTION_ID

az ml computetarget list --resource-group $resourcegroup_name --workspace-name $workspace_name

echo computetarget

$env:AML_COMPUTETARGET = $computetarget_name

