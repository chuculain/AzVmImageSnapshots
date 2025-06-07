# Generalize and capture a VM image for Azure Compute Gallery
# This script should be run after you have finished customizing your VM
# and want to create a generalized image for reuse.
#
# Usage:
#   - Set the variables below or pass them as parameters
#   - Run this script in PowerShell with Azure CLI installed and logged in
#
# Best practices:
#   - Never hardcode credentials
#   - Use error handling and logging
#   - Use managed identity or Azure CLI login for authentication

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    [Parameter(Mandatory=$true)]
    [string]$GalleryName,
    [Parameter(Mandatory=$true)]
    [string]$ImageDefinitionName,
    [Parameter(Mandatory=$true)]
    [string]$ImageVersion,
    [Parameter(Mandatory=$false)]
    [string]$Location = "canadacentral"
)

function ThrowIfFailed {
    param([int]$LastExitCode, [string]$Message)
    if ($LastExitCode -ne 0) {
        Write-Error $Message
        exit $LastExitCode
    }
}

Write-Host "[INFO] Deallocating VM..."
az vm deallocate --resource-group $ResourceGroupName --name $VMName
ThrowIfFailed $LASTEXITCODE "Failed to deallocate VM."

Write-Host "[INFO] Generalizing VM..."
az vm generalize --resource-group $ResourceGroupName --name $VMName
ThrowIfFailed $LASTEXITCODE "Failed to generalize VM."

Write-Host "[INFO] Creating image definition (if not exists)..."
az sig image-definition create `
  --resource-group $ResourceGroupName `
  --gallery-name $GalleryName `
  --gallery-image-definition $ImageDefinitionName `
  --publisher "customPublisher" `
  --offer "customOffer" `
  --sku "customSku" `
  --os-type Windows `
  --location $Location
ThrowIfFailed $LASTEXITCODE "Failed to create image definition."

Write-Host "[INFO] Creating image version..."
az sig image-version create `
  --resource-group $ResourceGroupName `
  --gallery-name $GalleryName `
  --gallery-image-definition $ImageDefinitionName `
  --gallery-image-version $ImageVersion `
  --managed-image "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMName" `
  --location $Location
ThrowIfFailed $LASTEXITCODE "Failed to create image version."

Write-Host "[SUCCESS] Generalized image captured and stored in Compute Gallery."
