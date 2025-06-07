param location string = 'canadacentral' 
param vmNamePrefix string = 'vm'
param adminUsername string
@secure()
param adminPassword string
param imageGalleryName string
param imageDefinitionName string
param imageVersion string = 'latest'
param instanceCount int = 1
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
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        id: galleryImage.id
        version: imageVersion
      }
      osDisk: {
        name: osDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diffDiskSettings: {
          option: 'Local'
          placement: 'CacheDisk'
        }
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
