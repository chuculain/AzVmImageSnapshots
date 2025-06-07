targetScope = 'subscription'

param location string = 'canadacentral' // Change as needed
param resourceGroupName string // <-- Enter your resource group name

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}
