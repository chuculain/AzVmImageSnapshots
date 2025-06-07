targetScope = 'resourceGroup'


param location string = 'canadacentral' 
param galleryName string // <-- Enter your compute gallery name
param vnetName string = 'vmVnet'
param subnetName string = 'vmSubnet'
param nsgName string = 'vmNsg'
param tags object = {
  environment: 'dev'
  project: 'AzVmImageSnapshots'
  owner: 'chuculain'
}

resource gallery 'Microsoft.Compute/galleries@2021-03-01' = {
  name: galleryName
  location: location
  properties: {}
  tags: tags
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.0.0.0/16' ] }
    subnets: [
      {
        name: subnetName
        properties: { addressPrefix: '10.0.0.0/24' }
      }
    ]
  }
  tags: tags
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: tags
}
