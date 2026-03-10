# Troubleshooting Guide

## Common Issues and Solutions

### 1. Terraform State Lock

**Error**: `Error acquiring the state lock`

**Solution**:

```bash
cd infra
terraform force-unlock LOCK_ID
```

### 2. Azure Authentication Failures

**Error**: `Error: building AzureRM Client: ... authentication failed`

**Solution**:

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription YOUR_SUBSCRIPTION_ID

# Verify credentials
az account show
```

### 3. Insufficient Permissions

**Error**: `AuthorizationFailed` or `Insufficient privileges`

**Solution**:

- Ensure your Azure account has **Owner** or **Contributor** role at subscription level
- Verify service principal has required permissions

### 4. GitHub Actions Failures

**Common Causes**:

- Invalid Azure credentials
- Missing GitHub secrets
- Insufficient permissions
- Network connectivity issues

**Debug Steps**:

1. Check GitHub Actions logs (go to Actions tab)
2. Verify all secrets are configured
3. Test credentials locally:
   ```bash
   az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET --tenant $TENANT_ID
   ```

### 5. Terraform Init Fails

**Error**: `Error: Failed to get existing workspaces`

**Solution**:

```bash
# Verify backend storage account exists and is accessible
az storage container exists \
  --account-name YOUR_STORAGE_ACCOUNT \
  --name tfstate

# Reinitialize
cd infra
rm -rf .terraform .terraform.lock.hcl  # Windows: remove-item -recurse .terraform
terraform init \
  -backend-config="resource_group_name=YOUR_RG" \
  -backend-config="storage_account_name=YOUR_SA" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=terraform.tfstate"
```

### 6. Docker Image Pull Failures

**Error**: `Pull from repository failed`

**Cause**: Invalid docker image name or registry credentials

**Solution**:

```hcl
# Use valid Docker Hub image
docker_image_name = "nginx:latest"
docker_registry_url = ""

# Or provide ACR credentials
docker_registry_url = "https://myregistry.azurecr.io"
docker_image_name = "myregistry.azurecr.io/myapp:latest"
```

### 7. App Service Health Check Failures

**Error**: App Service not responding after deployment

**Solution**:

```bash
# Check app service logs
az webapp log tail --resource-group RG_NAME --name APP_NAME

# Restart app service
az webapp restart --resource-group RG_NAME --name APP_NAME

# Check if running
curl https://APP_NAME.azurewebsites.net
```

### 8. RBAC Role Assignment Fails

**Error**: `Insufficient privileges to complete the operation`

**Cause**: Your account lacks `Microsoft.Authorization/roleAssignments/write` permission

**Solution**:

- Ask subscription owner to assign you **User Access Administrator** role
- Or ask them to manually create the role assignment

### 9. Managed Identity Not Working

**Error**: Application gets 403 Forbidden or authentication errors

**Solution**:

1. Verify managed identity is enabled:

   ```bash
   az webapp identity show \
     --resource-group RG_NAME \
     --name APP_NAME
   ```

2. Verify role assignment:

   ```bash
   PRINCIPAL_ID=$(az webapp identity show \
     --resource-group RG_NAME \
     --name APP_NAME \
     --query principalId -o tsv)

   az role assignment list --assignee $PRINCIPAL_ID
   ```

3. Restart the app service:
   ```bash
   az webapp restart --resource-group RG_NAME --name APP_NAME
   ```

### 10. Backend State File Locked

**Error**: `ConflictError: ResourceExistsError` during apply

**Solution**:

```bash
# Check if another operation is in progress
az storage blob lease break \
  --account-name YOUR_STORAGE_ACCOUNT \
  --container-name tfstate \
  --blob-name terraform.tfstate

# Retry Terraform
terraform apply -lock=false
```

## Debugging Commands

### View Terraform State

```bash
cd infra
terraform state list
terraform state show azurerm_linux_web_app.main
```

### View App Service Properties

```bash
az webapp show \
  --resource-group RG_NAME \
  --name APP_NAME \
  --query "{name:name,state:state,resourceGroup:resourceGroup}" -o json
```

### Check RBAC Assignments

```bash
az role assignment list \
  --resource-group RG_NAME \
  --all \
  --output json | jq '.[] | {principalName, roleDefinitionName, scope}'
```

### View Deployment Logs

```bash
# Azure Activity Log
az monitor activity-log list \
  --resource-group RG_NAME \
  --offset 1h \
  --query "[].{eventName:properties.eventName,status:status,eventTimestamp}" -o table

# App Service Logs
az webapp log download \
  --resource-group RG_NAME \
  --name APP_NAME \
  --log-file logs.zip
```

## Performance Issues

### Slow Deployment

1. Check network connectivity to Azure
2. Verify resource group location
3. Check if App Service Plan SKU is adequate
4. Monitor Azure service health

### High Latency

1. Choose closer Azure region in `terraform.tfvars`:

   ```hcl
   location = "westus"  # Or closest region to you
   ```

2. Enable App Service diagnostics to identify bottlenecks

## Support Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service Troubleshooting](https://learn.microsoft.com/en-us/azure/app-service/troubleshoot-common-app-service-errors)
- [Azure RBAC Troubleshooting](https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting)

## Contact Support

For persistent issues:

1. Collect diagnostic information
2. Review GitHub Actions logs
3. Check Azure Activity Log
4. Create an issue in the repository with diagnostics
