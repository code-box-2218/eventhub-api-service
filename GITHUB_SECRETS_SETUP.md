# GitHub Secrets Setup Guide

Your workflows now use **SERVICE_PRINCIPAL** authentication with individual credentials. Follow this guide to set up your GitHub secrets correctly.

## Required GitHub Secrets

You need to create these 3 secrets in your GitHub repository:

| Secret Name             | Description                 | How to Get                               |
| ----------------------- | --------------------------- | ---------------------------------------- |
| `AZURE_CLIENT_ID`       | Service Principal Client ID | From service principal creation          |
| `AZURE_TENANT_ID`       | Azure Tenant ID             | From service principal creation          |
| `AZURE_SUBSCRIPTION_ID` | Your Azure Subscription ID  | Run: `az account show --query id -o tsv` |

## Step 1: Create Azure Service Principal

```bash
# Login to Azure
az login

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "github-eventhub-api" \
  --role Contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID

# Output will look like:
# {
#   "appId": "CLIENT_ID",
#   "displayName": "github-eventhub-api",
#   "password": "CLIENT_SECRET",
#   "tenant": "TENANT_ID"
# }
```

**Save these values:**

- `appId` = `AZURE_CLIENT_ID`
- `tenant` = `AZURE_TENANT_ID`
- `password` = `AZURE_CLIENT_SECRET` (save it, but don't add to GitHub)

## Step 2: Get Subscription ID

```bash
az account show --query id -o tsv
```

## Step 3: Add GitHub Secrets

Go to your GitHub repository:

1. **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret** and add:

```
Name: AZURE_CLIENT_ID
Value: <appId from service principal>

Name: AZURE_TENANT_ID
Value: <tenant from service principal>

Name: AZURE_SUBSCRIPTION_ID
Value: <subscription id>
```

## ⚠️ Important Security Notes

1. **NEVER** commit the service principal password to Git
2. Keep `CLIENT_SECRET` only in your local Azure CLI
3. Only store the 3 public IDs in GitHub secrets
4. Rotate credentials regularly
5. Limit the service principal to only necessary scopes

## Verify Setup

Test your credentials locally:

```bash
az login --service-principal \
  --username YOUR_CLIENT_ID \
  --password YOUR_CLIENT_SECRET \
  --tenant YOUR_TENANT_ID

# Should show your subscription
az account show
```

## Troubleshooting

### "Login failed with Error: Using auth-type: SERVICE_PRINCIPAL"

- ✅ Verify all 3 secrets are configured correctly
- ✅ Check for trailing spaces in secret values
- ✅ Ensure `AZURE_SUBSCRIPTION_ID` is your actual subscription ID

### "Insufficient privileges"

- ✅ Service principal needs Contributor role at subscription level
- ✅ Run: `az role assignment create --assignee CLIENT_ID --role Contributor --scope /subscriptions/SUBSCRIPTION_ID`

### "Resource not found"

- ✅ Verify subscription ID is correct
- ✅ Check resource group doesn't already exist (conflicts with naming)

## Next Steps

1. Add the 3 secrets to GitHub
2. Test by pushing a commit to `main` branch
3. Check GitHub Actions logs for deployment progress
4. Once successful, your Event Hub API Service will be deployed! 🎉

## Need Help?

- Check GitHub Actions workflow logs
- Run local Terraform: `cd infra && terraform plan`
- Verify credentials: `az account show`
