// Bicep template for deploying a Windows 11 21H2 VM
// Moved from project root for best practices
// Add resource tags and comments for traceability
// Parameters should be set via parameter files or pipeline

param location string = 'canadacentral' // Laval, QC, Canada region
param vmName string // <-- Enter your VM name
param adminUsername string // <-- Enter your admin username
@secure()
param adminPassword string // <-- Enter your admin password (use a secure parameter in pipeline)
param vnetName string
param subnetName string
param tags object = {
  environment: 'dev'
  project: 'AzVmImageSnapshots'
  owner: '<your-name-or-alias>'
}

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
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-21h2-pro'
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
