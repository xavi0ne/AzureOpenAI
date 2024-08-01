//ASE module configured for ILB mode only//

param appSvcEnvironmentName string
param location string 
param financialTag string 
param ASEprivateDNSZoneName string = '${appSvcEnvironmentName}.appserviceenvironment.us'
param vmSize string 
param subnetId string
param appSvcEnvIP string

resource ase 'Microsoft.Web/hostingEnvironments@2023-12-01' = {
  name: appSvcEnvironmentName
  location: location
  kind: 'ASEV3'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    virtualNetwork: {
      id: subnetId
    }
    internalLoadBalancingMode: 'Web, Publishing'
    multiSize: vmSize
    frontEndScaleFactor: 15
    dedicatedHostCount: 0
    zoneRedundant: true
    clusterSettings: [
      {
        name: 'DisableTls1.0'
        value: '1'
      }
    ]
    networkingConfiguration: {
      properties: {
        inboundIpAddressOverride: appSvcEnvIP
        allowNewPrivateEndpointConnections: true
      }
    }
  }
  tags: {
    financial: financialTag
  } 
}

resource dnsARecord1 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${ASEprivateDNSZoneName}/*.scm'
  location: 'global'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: appSvcEnvIP
      }
    ]
  }
  dependsOn: [
    ase
  ]
}
resource dnsARecord2 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${ASEprivateDNSZoneName}/@'
  location: 'global'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: appSvcEnvIP
      }
    ]
  }
  dependsOn: [
    ase
  ]
}
resource dnsARecord3 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${ASEprivateDNSZoneName}/*'
  location: 'global'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: appSvcEnvIP
      }
    ]
  }
  dependsOn: [
    ase
  ]
}
