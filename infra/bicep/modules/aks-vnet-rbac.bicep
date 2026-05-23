// =============================================================================
// AKS VNet RBAC Module
// =============================================================================
// Grants the AKS managed identity Network Contributor on the custom VNet.
// This is required so the AKS cloud controller can manage NSG rules on the
// subnet for LoadBalancer services. Without this, the cloud controller falls
// back to the MC_ NIC NSG only, but the subnet NSG (evaluated first) blocks
// internet traffic with its default DenyAllInBound rule — causing the app
// to be unreachable after every cluster stop/start.
// =============================================================================

@description('Name of the VNet that AKS uses')
param vnetName string

@description('Principal ID of the AKS system-assigned managed identity')
param aksManagedIdentityPrincipalId string

// =============================================================================
// RESOURCES
// =============================================================================

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnetName
}

var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'

resource aksVnetRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vnet.id, aksManagedIdentityPrincipalId, networkContributorRoleId)
  scope: vnet
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
    principalId: aksManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}
