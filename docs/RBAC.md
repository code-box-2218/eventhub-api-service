# Azure RBAC Configuration

## Overview

This deployment includes automatic RBAC (Role-Based Access Control) configuration for the App Service.

## What is RBAC?

Azure RBAC is Azure's authorization system that allows you to manage who has access to Azure resources, what they can do with those resources, and what areas they have access to.

## Managed Identity

The App Service is configured with a **System-Assigned Managed Identity**. This is an identity that Azure creates and manages for you that your application can use for authentication.

### Benefits

- No credentials to manage
- Automatic rotation of secrets
- Secure authentication to other Azure services
- No shared secrets in code or config

## Role Assignment

### Current Configuration

```
App Service Managed Identity
    ↓
    └── Contributor Role
        └── Resource Group Scope
```

### Role Details

- **Principal Type**: System-Assigned Managed Identity
- **Role**: Contributor (can be changed via variable)
- **Scope**: Resource Group
- **Permissions**: Full control except RBAC management

## Available Roles

### Built-in Roles (Pre-configured)

| Role                          | Description                        | Use Case               |
| ----------------------------- | ---------------------------------- | ---------------------- |
| Reader                        | Read-only access to all resources  | Monitoring, auditing   |
| Contributor                   | Full access except RBAC management | Application operations |
| Owner                         | Full access including RBAC         | Admin operations       |
| Storage Blob Data Contributor | Read/write/delete blob storage     | Storage operations     |

### Assigning Different Roles

To use a different role, modify `terraform.tfvars`:

```hcl
rbac_role_name = "Storage Blob Data Contributor"
```

Then redeploy:

```bash
cd infra
terraform apply -var-file="terraform.tfvars"
```

## Custom RBAC Roles

For advanced scenarios, you can enable custom RBAC role assignment:

```hcl
enable_custom_rbac = true
custom_rbac_role_name = "CustomApplicationRole"
```

## Verifying RBAC Assignment

### Via Azure CLI

```bash
# Get the principal ID
PRINCIPAL_ID=$(az webapp identity show \
  --resource-group <RG_NAME> \
  --name <APP_NAME> \
  --query principalId -o tsv)

# List role assignments
az role assignment list --assignee $PRINCIPAL_ID --output json
```

### Via Azure Portal

1. Navigate to the App Service
2. Select "Identity" from the left menu
3. Go to "Azure role assignments"
4. View all assigned roles

## Using Managed Identity in Your Application

### .NET

```csharp
using Azure.Identity;
using Azure.Storage.Blobs;

// Use DefaultAzureCredential which automatically uses managed identity
var credential = new DefaultAzureCredential();
var client = new BlobContainerClient(new Uri("https://myaccount.blob.core.windows.net/mycontainer"), credential);
```

### Node.js

```javascript
const { DefaultAzureCredential } = require("@azure/identity");
const { BlobServiceClient } = require("@azure/storage-blob");

const credential = new DefaultAzureCredential();
const client = new BlobServiceClient(
  "https://myaccount.blob.core.windows.net",
  credential,
);
```

### Python

```python
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

credential = DefaultAzureCredential()
client = BlobServiceClient(
    account_url="https://myaccount.blob.core.windows.net",
    credential=credential
)
```

## Security Best Practices

1. **Least Privilege**: Use the smallest role that provides the necessary permissions
2. **Scope Limitation**: Assign roles at the most specific scope possible
3. **Regular Auditing**: Review role assignments regularly
4. **Monitoring**: Monitor and log access attempts
5. **No Secrets**: Never put secrets in code or environment variables

## Modifying RBAC After Deployment

To change the RBAC role:

1. Update `terraform.tfvars`:

   ```hcl
   rbac_role_name = "NewRoleName"
   ```

2. Apply changes:
   ```bash
   cd infra
   terraform plan
   terraform apply
   ```

## Troubleshooting

### Permission Denied Errors

If your application gets "Permission Denied" errors:

1. Verify the managed identity is assigned the correct role
2. Check the role has required permissions for the operation
3. Review the operation is scoped to the correct resource

### Managed Identity Not Working

1. Verify managed identity is enabled:

   ```bash
   az webapp identity show --resource-group <RG> --name <APP_NAME>
   ```

2. Verify role assignment exists:

   ```bash
   az role assignment list --assignee <PRINCIPAL_ID>
   ```

3. Restart the App Service to refresh credentials

## References

- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/)
- [Managed Identities for Azure Resources](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Built-in Azure Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
