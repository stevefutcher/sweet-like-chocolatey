var networkVars = loadJsonContent('./network-vars.json')

@description('The name of the VM to create')
param vmName string = 'ws25-debug'

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: networkVars.vaultName
  scope: resourceGroup(networkVars.networkGroup)
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${vmName}-ip'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {    
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${vmName}-${uniqueString(resourceGroup().name)}'
    }
  }
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.12.0' = {
  name: 'virtualMachineDeployment'
  params: {
    adminUsername: 'choco'
    imageReference: {
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: '2022-datacenter-smalldisk-g2'
      version: 'latest'
    }
    name: '${vmName}-vm'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig'
            subnetResourceId: resourceId(networkVars.networkGroup, 'Microsoft.Network/virtualNetworks/subnets',  networkVars.vnet, networkVars.vmSubnet)
            pipConfiguration: {
              publicIPAddressResourceId: publicIp.id
            }            
          }
        ]
        nicSuffix: '-nic'
        networkSecurityGroupResourceId: resourceId(networkVars.networkGroup, 'Microsoft.Network/networkSecurityGroups', networkVars.nsg)      }
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
    extensionCustomScriptConfig: {
      enabled: true
      fileData: [
        {
          uri: 'https://raw.githubusercontent.com/stevefutcher/sweet-like-chocolatey/refs/heads/main/iis-lets-encrypt-demo/iis-lets-encrypt.ps1'          
        }
      ]
    }
    extensionCustomScriptProtectedSetting: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File iis-lets-encrypt.ps1 -fqdn ${publicIp.properties.dnsSettings.fqdn}'
    }
  }
}
