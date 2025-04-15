var networkVars = loadJsonContent('./network-vars.json')

@description('The name of the VM to create')
param vmName string = 'dev'

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: networkVars.vaultName
  scope: resourceGroup(networkVars.networkGroup)
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.12.0' = {
  name: 'virtualMachineDeployment'
  params: {
    adminUsername: 'choco'
    imageReference: {
      offer: 'windows-11'
      publisher: 'MicrosoftWindowsDesktop'
      sku: 'win11-24h2-entn'
      version: 'latest'
    }
    name: '${vmName}-vm'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig'
            subnetResourceId: resourceId(networkVars.networkGroup, 'Microsoft.Network/virtualNetworks/subnets',  networkVars.vnet, networkVars.vmSubnet)
          }
        ]
        nicSuffix: '-nic'        
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: 256
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_F8s_v2'    
    encryptionAtHost: false
    zone: 0
    // Non-required parameters
    adminPassword: vault.getSecret('vm-password')
    location: resourceGroup().location
  }
}

