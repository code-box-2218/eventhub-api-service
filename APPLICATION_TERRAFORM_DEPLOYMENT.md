# Event Hub API Service - Terraform Deployment Guide

## Complete Step-by-Step Documentation

### Overview

This guide provides consolidated steps to deploy the Event Hub API Service infrastructure using Terraform and GitHub Actions. Follow these steps in order for a successful deployment.

---

## Part 1: Azure Setup

### Step 1.1: Create Service Principal

Create a service principal in Azure for CI/CD authentication.

```bash
# Command
az ad sp create-for-rbac \
  --name github-eventhub-api \
  --role Contributor \
  --scopes "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
```

**Output Values (Save Securely):**

- `appId` → **AZURE_CLIENT_ID**
- `password` → **AZURE_CLIENT_SECRET** (⚠️ Save this - you won't see it again!)
- `tenantId` → **AZURE_TENANT_ID**
- Subscription → **AZURE_SUBSCRIPTION_ID**

**Example Output Format:**

```json
{
  "appId": "<YOUR_CLIENT_ID>",
  "displayName": "github-eventhub-api",
  "password": "<YOUR_CLIENT_SECRET>",
  "tenant": "<YOUR_TENANT_ID>"
}
```

### Step 1.2: Verify Azure Subscription

```bash
az account show
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

---

## Part 2: GitHub Repository Setup

### Step 2.1: Choose Repository

Your Terraform code should be in an organization repository. Example:

- **Repository**: `code-box-2218/eventhub-api-service`
- **Visibility**: Private
- **Default Branch**: main

### Step 2.2: Push Infrastructure Code

```bash
# Navigate to your local workspace
cd your-workspace

# Set git remote to your organization repo
git remote set-url origin https://github.com/code-box-2218/eventhub-api-service.git

# Push to main branch
git branch -M main
git push -u origin main
```

### Step 2.3: Verify Repository Contents

Your repository should contain:

```
code-box-2218/eventhub-api-service/
├── infra/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── scripts/
│   ├── setup-github-secrets.ps1
│   ├── setup-secrets.ps1
│   └── setup-secrets.sh
├── .github/
│   └── workflows/
│       └── eventhub-api-service-deploy.yml
├── docs/
│   ├── RBAC.md
│   └── TROUBLESHOOTING.md
├── README.md
└── APPLICATION_TERRAFORM_DEPLOYMENT.md
```

---

## Part 3: GitHub Secrets Configuration

### Step 3.1: Set GitHub Secrets

Set these 4 secrets in your GitHub repository:

**Via GitHub CLI:**

```bash
# Set secrets in your organization repository
# Replace placeholders with your actual values from Step 1.1

gh secret set AZURE_CLIENT_ID \
  --body "<YOUR_CLIENT_ID>" \
  --repo "code-box-2218/eventhub-api-service"

gh secret set AZURE_CLIENT_SECRET \
  --body "<YOUR_CLIENT_SECRET>" \
  --repo "code-box-2218/eventhub-api-service"

gh secret set AZURE_TENANT_ID \
  --body "<YOUR_TENANT_ID>" \
  --repo "code-box-2218/eventhub-api-service"

gh secret set AZURE_SUBSCRIPTION_ID \
  --body "<YOUR_SUBSCRIPTION_ID>" \
  --repo "code-box-2218/eventhub-api-service"
```

**Via GitHub Web UI:**

1. Go to: Repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret with your actual values

### Step 3.2: Verify Secrets Are Set

```bash
gh secret list --repo "code-box-2218/eventhub-api-service"
```

**Expected Output:**

```
NAME                   UPDATED
AZURE_CLIENT_ID        less than a minute ago
AZURE_CLIENT_SECRET    less than a minute ago
AZURE_SUBSCRIPTION_ID  less than a minute ago
AZURE_TENANT_ID        less than a minute ago
```

---

## Part 4: Workflow File Configuration

### Step 4.1: Create/Update Workflow File

**Location:** `.github/workflows/eventhub-api-service-deploy.yml`

**Key Configuration:**

```yaml
name: Deploy Event Hub API Service

on:
  push:
    branches:
      - main
    paths:
      - "infra/**"
      - ".github/workflows/eventhub-api-service-deploy.yml"
  pull_request:
    branches:
      - main
  workflow_dispatch:

env:
  TERRAFORM_VERSION: 1.5.0
```

### Step 4.2: Azure Login Configuration

**CRITICAL:** Use `creds` in JSON format (not individual parameters)

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: |
      {
        "clientId": "${{ secrets.AZURE_CLIENT_ID }}",
        "clientSecret": "${{ secrets.AZURE_CLIENT_SECRET }}",
        "subscriptionId": "${{ secrets.AZURE_SUBSCRIPTION_ID }}",
        "tenantId": "${{ secrets.AZURE_TENANT_ID }}"
      }
```

✅ **Note:** The `${{ }}` syntax properly interpolates secrets in YAML

### Step 4.3: Terraform Configuration

**Jobs in workflow:**

1. **terraform-validate** - Validates syntax and format
2. **terraform-plan** - Creates deployment plan (shows what will be created)
3. **terraform-apply** - Deploys infrastructure to Azure

**Terraform Variables:**

```bash
-var="subscription_id=${{ secrets.AZURE_SUBSCRIPTION_ID }}"
-var="app_name=eventhub-api"
-var="resource_group_name=rg-eventhub-api"
-var="location=eastus"
-var="app_service_sku=B1"
-var="enable_eventhub=true"
```

---

## Part 5: Deployment Process

### Step 5.1: Trigger Deployment

**Option A - Push to main branch:**

```bash
git push origin main
```

This automatically triggers the workflow when changes are pushed to `infra/` files or the workflow file.

**Option B - Manual workflow trigger:**

```bash
gh workflow run eventhub-api-service-deploy.yml \
  --repo "code-box-2218/eventhub-api-service"
```

### Step 5.2: Monitor Deployment

**Via CLI:**

```bash
# List workflow runs
gh run list --repo "code-box-2218/eventhub-api-service" \
  --workflow "eventhub-api-service-deploy.yml" --limit 5

# View specific run details
gh run view <run-number> \
  --repo "code-box-2218/eventhub-api-service" --verbose

# View failed run logs
gh run view <run-number> \
  --repo "code-box-2218/eventhub-api-service" --log-failed
```

**Via Web UI:**

- Go to: https://github.com/code-box-2218/eventhub-api-service/actions
- Click the latest "Deploy Event Hub API Service" run
- Monitor each job's progress in real-time

---

## Part 6: Deployment Outputs

### Step 6.1: Retrieve Deployment Outputs

After successful deployment, get the outputs:

```bash
cd infra/
terraform output app_service_url
terraform output app_service_name
terraform output eventhub_name
```

### Step 6.2: Expected Resources Created

✅ **Resources Deployed:**

- **App Service**: `app-eventhub-api` (B1 SKU)
- **Event Hub**: `evh-eventhub-api`
- **Resource Group**: `rg-eventhub-api`
- **Location**: East US
- **Managed Identity**: Configured for Event Hub access
- **Storage**: Terraform state

---

## Part 7: Troubleshooting

### Issue 1: "Invalid client secret provided"

**Cause:** Client secret is expired or invalid (valid for ~1 year)

**Solution:**

```bash
# Get your service principal's Object ID
az ad sp show --id "<YOUR_CLIENT_ID>" | ConvertFrom-Json | Select-Object -ExpandProperty id

# Create new secret (replace with the ID from above)
az ad sp credential reset --id "<OBJECT_ID>" --years 1 | ConvertFrom-Json | Select-Object -ExpandProperty password

# Copy the new password and update GitHub secret
gh secret set AZURE_CLIENT_SECRET \
  --body "<NEW_PASSWORD>" \
  --repo "code-box-2218/eventhub-api-service"

# Trigger workflow again
gh workflow run eventhub-api-service-deploy.yml \
  --repo "code-box-2218/eventhub-api-service"
```

### Issue 2: "Terraform Format Check Failed"

**Cause:** Terraform files not properly formatted

**Solution:**

```bash
cd infra/
terraform fmt -recursive
git add .
git commit -m "Fix Terraform formatting"
git push origin main
```

### Issue 3: "Login failed - Unable to authenticate"

**Cause:** Secrets not properly set or wrong values

**Solution:**

```bash
# Verify all secrets are set
gh secret list --repo "code-box-2218/eventhub-api-service"

# Check if values are correct (don't print actual secrets)
# Ensure:
# - AZURE_CLIENT_ID matches your service principal App ID
# - AZURE_CLIENT_SECRET is the password (not the ID)
# - AZURE_TENANT_ID matches your Azure tenant
# - AZURE_SUBSCRIPTION_ID is correct
```

### Issue 4: "Repository not found or insufficient permissions"

**Cause:** Wrong repository path or insufficient GitHub permissions

**Solution:**

```bash
# Verify repository exists and you have access
gh repo view code-box-2218/eventhub-api-service

# Check your authentication
gh auth status

# If needed, re-authenticate
gh auth login
```

### Issue 5: Push rejected due to secrets

**Cause:** GitHub detected actual secrets in your files

**Solution:**

- Always use `<YOUR_PLACEHOLDER>` format in documentation
- Never hardcode real secrets in files that will be committed
- Use GitHub secrets (${{ secrets.NAME }}) in workflows
- If you accidentally committed secrets, use the provided link to approve the push

---

## Part 8: Security Best Practices

### Do's ✅

- ✅ Rotate client secrets annually
- ✅ Use repository secrets (${{ secrets.NAME }})
- ✅ Never hardcode credentials in files
- ✅ Use private repositories for infrastructure
- ✅ Enable branch protection on main
- ✅ Use service principals (not personal accounts)
- ✅ Use minimal required permissions
- ✅ Audit and review GitHub Actions logs

### Don'ts ❌

- ❌ Don't commit secrets to version control
- ❌ Don't share credentials via Slack/email
- ❌ Don't use personal credentials for CI/CD
- ❌ Don't use overly permissive roles
- ❌ Don't keep expired credentials active
- ❌ Don't hardcode values in workflows
- ❌ Don't share Terraform state files publicly
- ❌ Don't commit `.tfstate` files

---

## Part 9: Next Steps After Deployment

1. **Verify Resources in Azure:**

   ```bash
   az resource list --resource-group rg-eventhub-api
   az app service list --resource-group rg-eventhub-api
   ```

2. **Test App Service:**

   ```bash
   curl https://app-eventhub-api.azurewebsites.net/health
   ```

3. **Deploy Your Application:**
   - Push Spring Boot application code
   - Configure connection strings if needed
   - Deploy to App Service using your deployment method

4. **Configure Monitoring:**
   - Enable Application Insights
   - Set up Azure Alerts
   - Configure Azure Monitor dashboards
   - Enable Event Hub metrics

5. **Scale for Production:**
   - Update `app_service_sku` variable for higher tier (S1, P1, etc.)
   - Configure autoscaling based on metrics
   - Set up disaster recovery

---

## Part 10: Key Commands Reference

### Service Principal Management

```bash
# Create service principal
az ad sp create-for-rbac --name github-eventhub-api --role Contributor --scopes "/subscriptions/<ID>"

# Get service principal info
az ad sp show --id "<CLIENT_ID>"

# Reset credentials
az ad sp credential reset --id "<OBJECT_ID>" --years 1

# List service principals
az ad sp list --display-name github-eventhub-api
```

### GitHub Actions Management

```bash
# List workflow runs
gh run list --repo "owner/repo" --workflow "workflow-name"

# View run details
gh run view <run-id> --repo "owner/repo"

# View run logs
gh run view <run-id> --repo "owner/repo" --log

# Trigger workflow manually
gh workflow run <workflow-name> --repo "owner/repo"

# List secrets
gh secret list --repo "owner/repo"

# Set secret
gh secret set NAME --body "value" --repo "owner/repo"
```

### Terraform Commands

```bash
# Validate configuration
cd infra/
terraform validate

# Format code
terraform fmt -recursive

# Plan deployment
terraform plan

# Apply deployment
terraform apply -auto-approve

# View outputs
terraform output
```

---

## Part 11: File Structure and Locations

### Configuration Files

- **Workflow**: `.github/workflows/eventhub-api-service-deploy.yml`
- **Terraform**: `infra/main.tf`, `infra/variables.tf`, `infra/outputs.tf`
- **Setup Scripts**: `scripts/setup-github-secrets.ps1`, `scripts/setup-secrets.sh`
- **Documentation**: `docs/TROUBLESHOOTING.md`, `docs/RBAC.md`

### Important Paths

- **Repository**: `https://github.com/code-box-2218/eventhub-api-service`
- **Actions**: `https://github.com/code-box-2218/eventhub-api-service/actions`
- **Secrets**: `https://github.com/code-box-2218/eventhub-api-service/settings/secrets/actions`
- **Settings**: `https://github.com/code-box-2218/eventhub-api-service/settings`

---

## Support & Useful Links

### Official Documentation

- [Azure Login Action](https://github.com/Azure/login)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Azure Service Principal](https://learn.microsoft.com/en-us/cli/azure/ad/sp)

### Troubleshooting Resources

- See: `docs/TROUBLESHOOTING.md` for detailed error solutions
- See: `docs/RBAC.md` for permission issues
- See: `QUICK_START.md` for quick reference

---

## Summary

### Quick Checklist

- [ ] Service principal created (Step 1.1)
- [ ] Credentials saved securely (Step 1.1)
- [ ] Code pushed to repository (Step 2.2)
- [ ] All 4 GitHub secrets set (Step 3.1)
- [ ] Workflow file in place (Step 4)
- [ ] Deployment triggered (Step 5.1)
- [ ] Deployment completed successfully
- [ ] Resources verified in Azure
- [ ] Application deployed to App Service
- [ ] Monitoring configured

---

**Version:** 1.0  
**Last Updated:** March 11, 2026  
**Status:** ✅ Verified and Production Ready

**Next Time:** Simply follow this guide step-by-step for consistent, reliable deployments.
