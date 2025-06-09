param location string = 'canadacentral' 
param vmNamePrefix string = 'vm'
param adminUsername string
param keyVaultName string
param adminPasswordSecretName string
// Retrieve the admin password from Key Vault
var adminPasswordFromKeyVault = reference(resourceId('Microsoft.KeyVault/vaults/secrets', keyVaultName, adminPasswordSecretName), '2015-06-01').secretValue
param imageGalleryName string
param imageDefinitionName string
param vmSize string = 'Standard_DS1_v2'
param networkInterfaceName string = 'nic'
param publicIpAddressName string = 'ip'
param virtualNetworkName string = 'vnet'
param subnetName string = 'subnet'
param osDiskName string = 'osdisk'
param tags object = {
  environment: 'dev'
  project: 'AzVmImageSnapshots'
  owner: 'chuculain'
}

// This Bicep file deploys a VM from an Azure Compute Gallery image with an ephemeral OS disk.
// It is designed for use in pipeline 3 as described in the project README.md.
//
// Parameters should be provided via parameter files or pipeline variables for security and flexibility.
//
// Resource names should follow Sumerian mythology naming conventions as per project standards.
//
// For production, inject secrets via Azure Key Vault or pipeline secrets.

resource galleryImage 'Microsoft.Compute/galleries/images@2021-03-01' existing = {
  name: '${imageGalleryName}/${imageDefinitionName}'
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: '${vmNamePrefix}-${uniqueString(resourceGroup().id)}'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${vmNamePrefix}-${uniqueString(resourceGroup().id)}'
      adminUsername: adminUsername
      adminPassword: adminPasswordFromKeyVault
    }
    storageProfile: {
      imageReference: {
        id: '${galleryImage.id}/versions/latest'
      }
      osDisk: {
        name: osDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diffDiskSettings: {
          option: 'Local'
          placement: 'CacheDisk'
        }
        tags: tags
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
  }
  tags: tags
}

resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2021-02-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  tags: tags
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

output adminUsernameOutput string = adminUsername
output vmNameOutput string = vm.name
output publicIpAddressOutput string = publicIpAddress.name
