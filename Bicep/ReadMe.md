# Azure OpenAI (AOAI) using Azure Functions

## Automate AOAI securely using App Svc Environment V3 and Azure Functions

### IaC guidance
+ Templates developed assume you are using an Azure US Government subscription.
+ Ensure to have your local environment configured with .Net Version 6 or later, and Bicep CLI before attempting to deploy IaC.
+ The following existing resources must already be deployed to leverage IaC Bicep templates:
  + A VNET with a dedicate subnet delegated to resource type 'Microsoft.Web/hostingEnvironment'.
  + Azure Key Vault; Once AOAI resource is deployed, ensure to add the AOAI access key to the vault. 
+ Once Azure Functions is deployed, ensure to configure RBAC 'Key Vault Secret User' scoped to existing Key Vault resource.
 
