targetScope='subscription'

param resourceGroupName string = 'azureml-rg-aipd218'
param resourceGroupLocation string = 'germanywestcentral'

resource newRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
} 
