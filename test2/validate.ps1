Param(
    [Parameter(Mandatory = $True)][string]$templateLibraryName = "name of template",
    [Parameter(Mandatory = $True)][string]$templateLibraryVersion = "version of template",
    [string]$templateName = "azuredeploy.json",
    [string]$containerName = "library-dev",
    [string]$prodContainerName = "library",
    [string]$storageRG = "PwS2-Infra-Storage-RG",
    [string]$storageAccountName = "azpwsdeploytpnjitlh3orvq",
    [string]$Location = "canadacentral"
)

$devBaseTemplateUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/arm"
$gcLibraryUrl = "https://azpwsdeployment.blob.core.windows.net/library/arm"

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# Start the deployment
Write-Host "Starting deployment...";

# Building dependencies needed for the server validation
New-AzureRmDeployment -Location $Location -Name "dependancy-$templateLibraryName-Build-resourcegroups" -TemplateUri "$gcLibraryUrl/resourcegroups/20190207.2/$templateName" -TemplateParameterFile (Resolve-Path "$PSScriptRoot\dependancy-resourcegroups-canadacentral.parameters.json") -Verbose

# Cleanup validation resource content
Write-Host "Cleanup validation resource content...";
New-AzureRmResourceGroupDeployment -ResourceGroupName PwS2-validate-loadbalancers-1-RG -Mode Complete -TemplateFile (Resolve-Path "$PSScriptRoot\cleanup.json") -Force -Verbose

# Validating server template
New-AzureRmResourceGroupDeployment -ResourceGroupName PwS2-validate-loadbalancers-1-RG -Name "validate-$templateLibraryName-Build-$templateLibraryName" -TemplateUri "$devBaseTemplateUrl/loadbalancers/$templateLibraryVersion/$templateName" -TemplateParameterFile (Resolve-Path "$PSScriptRoot\validate-loadbalancers.parameters.json") -Verbose

# Cleanup validation resource content
Write-Host "Cleanup validation resource content...";
New-AzureRmResourceGroupDeployment -ResourceGroupName PwS2-validate-loadbalancers-1-RG -Mode Complete -TemplateFile (Resolve-Path "$PSScriptRoot\cleanup.json") -Force -Verbose

