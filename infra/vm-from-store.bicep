// Bicep template for deploying a Windows 11 24H2 VM
// Moved from project root for best practices
// Add resource tags and comments for traceability
// Parameters should be set via parameter files or pipeline

param location string = 'canadacentral' // Laval, QC, Canada region
param vmName string // <-- Enter your VM name
param adminUsername string // <-- Enter your admin username
param keyVaultName string
param adminPasswordSecretName string
param vnetName string
param subnetName string
param owner string // <-- Enter your name or alias for the owner tag
param tags object = {
  environment: 'dev'
  project: 'AzVmImageSnapshots'
  owner: owner
}

var adminPasswordFromKeyVault = reference(resourceId('Microsoft.KeyVault/vaults/secrets', keyVaultName, adminPasswordSecretName), '2024-11-01').secretValue

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  tags: tags
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' } // Cheap platform
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordFromKeyVault
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-24h2-pro'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: nic.id }
      ]
    }
  }
  tags: tags
}
