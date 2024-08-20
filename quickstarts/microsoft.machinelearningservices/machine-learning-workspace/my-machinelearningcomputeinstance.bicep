// Creates compute resources in the specified machine learning workspace
// Includes Compute Instance, Compute Cluster and attached Azure Kubernetes Service compute types
@description('Prefix for resource names')
param prefix string = 'aipd218'

@description('Azure Machine Learning workspace to create the compute resources in')
param machineLearning string = 'ws-aipd218poc'

@description('Azure region of the deployment')
param location string = 'germanywestcentral'

@description('Tags to add to the resources')
param tags object = {}

// @description('Resource ID of the compute subnet')
// param computeSubnetId string

// @description('Name of the Azure Kubernetes services resource')
// param aksName string

// @description('Resource ID of the Azure Kubernetes services resource')
// param aksSubnetId string

// @description('Resource ID of the Azure Kubernetes services resource')
// param amlComputePublicIp bool = true

@description('VM size for the default compute cluster')
param vmSizeParam string = 'Standard_E4ds_v4'

// resource machineLearningCluster001 'Microsoft.MachineLearningServices/workspaces/computes@2022-05-01' = {
//   name: '${machineLearning}/cluster001'
//   location: location
//   identity: {
//     type: 'SystemAssigned'
//   }
//   tags: tags
//   properties: {
//     computeType: 'AmlCompute'
//     computeLocation: location
//     description: 'Machine Learning cluster 001'
//     disableLocalAuth: true
//     properties: {
//       vmPriority: 'Dedicated'
//       vmSize: vmSizeParam
//       enableNodePublicIp: amlComputePublicIp
//       isolatedNetwork: false
//       osType: 'Linux'
//       remoteLoginPortPublicAccess: 'Disabled'
//       scaleSettings: {
//         minNodeCount: 0
//         maxNodeCount: 5
//         nodeIdleTimeBeforeScaleDown: 'PT120S'
//       }
//       subnet: {
//         id: computeSubnetId
//       }
//     }
//   }
// }

resource machineLearningComputeInstance001 'Microsoft.MachineLearningServices/workspaces/computes@2022-05-01' = {
  name: '${machineLearning}/${prefix}-ci001'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    computeType: 'ComputeInstance'
    computeLocation: location
    description: 'Machine Learning compute instance 001'
    disableLocalAuth: true
    properties: {
      applicationSharingPolicy: 'Personal'
      
      computeInstanceAuthorizationType: 'personal'
      sshSettings: {
        sshPublicAccess: 'Disabled'
      }
      // subnet: {
      //   id: computeSubnetId
      // }
      vmSize: vmSizeParam
    }
  }
}

// module machineLearningAksCompute 'privateaks.bicep' = {
//   name: aksName
//   scope: resourceGroup()
//   params: {
//     location: location
//     tags: tags
//     aksClusterName: aksName
//     computeName: aksName
//     aksSubnetId: aksSubnetId
//     workspaceName: machineLearning
//     vmSizeParam: vmSizeParam
//   }
// }
