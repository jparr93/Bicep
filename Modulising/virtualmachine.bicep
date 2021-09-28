param resourcename string
param resourcetags object
param resourceidentity object
param resourceplan object
param resourcezones array


resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: resourcename
  location: 'string'
  tags: resourcetags
  identity: resourceidentity
  plan: resourceplan
  properties:  {
    additionalCapabilities: {
      ultraSSDEnabled: bool
    }
    availabilitySet: {
      id: 'string'
    }
  
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: bool
        storageUri: 'string'
      }
    }
    hardwareProfile: {
      vmSize: 'string'
    }
    licenseType: 'string'
    networkProfile: {
      networkInterfaces: [
        {
          id: 'string'
          properties: {
            deleteOption: 'string'
            primary: bool
          }
        }
      ]
    }
    osProfile: {
      adminPassword: 'string'
      adminUsername: 'string'
      allowExtensionOperations: bool
      computerName: 'string'
      customData: 'string'
      linuxConfiguration: {
        disablePasswordAuthentication: bool
        patchSettings: {
          assessmentMode: 'string'
          patchMode: 'string'
        }
        provisionVMAgent: bool
        ssh: {
          publicKeys: [
            {
              keyData: 'string'
              path: 'string'
            }
          ]
        }
      }
      requireGuestProvisionSignal: bool
      secrets: [
        {
          sourceVault: {
            id: 'string'
          }
          vaultCertificates: [
            {
              certificateStore: 'string'
              certificateUrl: 'string'
            }
          ]
        }
      ]
      windowsConfiguration: {
        additionalUnattendContent: [
          {
            componentName: 'Microsoft-Windows-Shell-Setup'
            content: 'string'
            passName: 'OobeSystem'
            settingName: 'string'
          }
        ]
        enableAutomaticUpdates: bool
        patchSettings: {
          assessmentMode: 'string'
          enableHotpatching: bool
          patchMode: 'string'
        }
        provisionVMAgent: bool
        timeZone: 'string'
        winRM: {
          listeners: [
            {
              certificateUrl: 'string'
              protocol: 'string'
            }
          ]
        }
      }
    }
    platformFaultDomain: int
    priority: 'string'
    proximityPlacementGroup: {
      id: 'string'
    }
    scheduledEventsProfile: {
      terminateNotificationProfile: {
        enable: bool
        notBeforeTimeout: 'string'
      }
    }
    securityProfile: {
      encryptionAtHost: bool
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: bool
        vTpmEnabled: bool
      }
    }
    storageProfile: {
      dataDisks: [
        {
          createOption: 'string'
          deleteOption: 'string'
          detachOption: 'ForceDetach'
          diskSizeGB: int
          image: {
            uri: 'string'
          }
          lun: int
          managedDisk: {
            diskEncryptionSet: {
              id: 'string'
            }
            id: 'string'
            storageAccountType: 'string'
          }
          name: 'string'
          toBeDetached: bool
          vhd: {
            uri: 'string'
          }
          writeAcceleratorEnabled: bool
        }
      ]
      imageReference: {
        id: 'string'
        offer: 'string'
        publisher: 'string'
        sku: 'string'
        version: 'string'
      }
      osDisk: {
        createOption: 'string'
        deleteOption: 'string'
        diffDiskSettings: {
          option: 'Local'
          placement: 'string'
        }
        diskSizeGB: int
        encryptionSettings: {
          diskEncryptionKey: {
            secretUrl: 'string'
            sourceVault: {
              id: 'string'
            }
          }
          enabled: bool
          keyEncryptionKey: {
            keyUrl: 'string'
            sourceVault: {
              id: 'string'
            }
          }
        }
        image: {
          uri: 'string'
        }
        managedDisk: {
          diskEncryptionSet: {
            id: 'string'
          }
          id: 'string'
          storageAccountType: 'string'
        }
        name: 'string'
        osType: 'string'
        vhd: {
          uri: 'string'
        }
        writeAcceleratorEnabled: bool
      }
    }
    userData: 'string'
    virtualMachineScaleSet: {
      id: 'string'
    }
  }
  zones: resourcezones
}