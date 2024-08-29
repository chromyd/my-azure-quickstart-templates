@description('Specifies the name of the deployment.')
param name string = 'aipd218'

@description('Specifies the name of the environment.')
param environment string = 'poc'

@description('Specifies the location of the Azure Machine Learning workspace and dependent resources.')
param location string = 'germanywestcentral'

param adGroupObjectId string = 'b2099344-15c1-42c1-9419-b212b96a2a98'

var tenantId = subscription().tenantId
var storageAccountName = 'st${name}${environment}'
var keyVaultName = 'kv-${name}-${environment}'
var applicationInsightsName = 'appi-${name}-${environment}'
// var containerRegistryName = 'cr${name}${environment}'
var workspaceName = 'ws-${name}${environment}'
var storageAccountId = storageAccount.id
var keyVaultId = vault.id
var applicationInsightId = applicationInsight.id
// var containerRegistryId = registry.id

resource UserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'uai${name}${environment}'
  location: location
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enableSoftDelete: true
  }
}

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

/*
resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  sku: {
    name: 'Standard'
  }
  name: containerRegistryName
  location: location
  properties: {
    adminUserEnabled: false
  }
}
*/

resource MachineLearningWorkspace 'Microsoft.MachineLearningServices/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  identity: {
    type: 'SystemAssigned' // TO-DO beyond POC: replace with UAI -> it can be used to grant access to Storage Account and other services
  }
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightId
    // containerRegistry: containerRegistryId // works without container registry, besides we currently lack permissions for it
  }
}

resource AzureMLComputeOperatorRole  'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: 'AzureML Compute Operator'
}

resource AzureMLDataScientistRole  'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: 'AzureML Data Scientist'
}

// resource AdGroupRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid('')
//   scope: 
//   properties: {
//     roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', AiDevopsRole.id)
//     principalId: adGroupObjectId
//   }
// }

param azureMLComputeOperatorRoleId string = 'e503ece1-11d0-4e8e-8e2c-7a6c3bf38815'
param azureMLDataScientistRoleId string = 'f6c7c914-8db3-469d-8ca1-694a8f32e121'

resource WorkspaceRoleAssignmentForOps 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: MachineLearningWorkspace
  name: guid(MachineLearningWorkspace.id, azureMLComputeOperatorRoleId, adGroupObjectId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureMLComputeOperatorRoleId)
    principalId: adGroupObjectId
  }
}
resource WorkspaceRoleAssignmentForDataScience 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: MachineLearningWorkspace
  name: guid(MachineLearningWorkspace.id, azureMLDataScientistRoleId, adGroupObjectId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureMLDataScientistRoleId)
    principalId: adGroupObjectId
  }
}
