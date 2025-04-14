@description('The user object Id for the demo user')
param demoUserId string

var networkVars = loadJsonContent('./network-vars.json')

resource networkSecGroup 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
    name: networkVars.nsg
    location: resourceGroup().location
    properties: {
      securityRules: [
        {
          name:'Allow_Http_Inbound'
          properties: {
            protocol: 'Tcp'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
            sourcePortRange: '*'
            sourcePortRanges: []
            sourceAddressPrefix: '*'
            sourceAddressPrefixes: []
            destinationAddressPrefix: '*'                    
            destinationAddressPrefixes: []
            destinationPortRanges: [
              '80'
              '443'
            ]
          }
        }
      ]
    }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
    name: networkVars.vnet
    location: resourceGroup().location
    properties: {
        addressSpace: {
            addressPrefixes: ['10.1.0.0/16']
        }
        subnets: [
            {
                name: 'AzureBastionSubnet'
                properties: {
                    addressPrefix: '10.1.1.0/24'
                }
            }
            {
                name: networkVars.vmSubnet
                properties: {
                    addressPrefix: '10.1.2.0/24'
                }
            }
        ]
    }
}

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
    name: networkVars.bastionIp
    location: resourceGroup().location
    sku: {
        name:'Standard'
    }
    properties: {
        publicIPAddressVersion: 'IPv4'
        publicIPAllocationMethod: 'Static'        
    }    
}

module bastionHost 'br:mcr.microsoft.com/bicep/avm/res/network/bastion-host:0.5.0' = {
    name: networkVars.bastionName
    params: {
        name: networkVars.bastionName
        virtualNetworkResourceId: virtualNetwork.id
        bastionSubnetPublicIpResourceId: bastionPublicIp.id
    }
}

@secure()
param vmPassword string = newGuid()

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: networkVars.vaultName
  location: resourceGroup().location
  properties: {
      enabledForDiskEncryption: false
      enabledForTemplateDeployment: true
      enableRbacAuthorization: true
      tenantId: subscription().tenantId
      enableSoftDelete: true
      softDeleteRetentionInDays: 90        
      sku: {
        name: 'standard'
        family: 'A'
      }
      networkAcls: {
        defaultAction: 'Allow'
        bypass: 'AzureServices'
      }
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'vm-password'
  properties: {
    value: vmPassword
  }
}

var keyVaultSecretOfficerPermission = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'


@description('The built-in resource definition of the group and role')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  resourceGroup()
  name: keyVaultSecretOfficerPermission
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, keyVaultSecretOfficerPermission, demoUserId)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: demoUserId
    principalType: 'User'
  }
}
