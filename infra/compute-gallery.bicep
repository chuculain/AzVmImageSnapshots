targetScope = 'resourceGroup'


param location string = 'canadacentral' 
param galleryName string // <-- Enter your compute gallery name
param vnetName string = 'dcacevnet'
param subnetName string = 'dcacesubnet'
param nsgName string = 'dcacensg'
param tags object = {
  environment: 'dev'
  project: 'AzVmImageSnapshots'
  owner: 'chuculain'
}

// Optional: Integrate Key Vault for secrets management in downstream deployments.
// For this module, no secrets are required, but you can pass the Key Vault name as a parameter for consistency and future use.
param keyVaultName string = '' // Optional: Provide Key Vault name for secret integration in other modules
//
// To use secrets from Key Vault in parameter files, use the following syntax in your parameter file:
// "adminPassword": { "reference": { "keyVault": { "id": "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.KeyVault/vaults/<vaultName>" }, "secretName": "<secretName>" } }
//
// This allows secure injection of secrets at deployment time.

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

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = if (keyVaultName != '') {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [] // Add access policies as needed
    enableSoftDelete: true
  }
  tags: tags
}

output keyVaultNameOutput string = keyVaultName // Output for downstream use if needed
