# Azure Resource Group Deployment Guide

This repository contains Infrastructure-as-Code (IaC) for deploying an Azure Resource Group ready for API Management services using Terraform and GitHub Actions CI/CD pipeline.

## 📋 Architecture

```
Azure Resource Group
└── rg-api-mgt (Ready for app deployment)
```

## 🚀 Quick Start

### Prerequisites

1. **Azure Account** - An active Azure subscription
2. **Terraform** - Version 1.5.0 or later
3. **Azure CLI** - Installed and configured
4. **GitHub Repository** - With Actions enabled

### Local Deployment

#### 1. Get Your Subscription ID

```bash
az login
az account show --query id -o tsv
```

#### 2. Configure Variables

Edit `infra/terraform.tfvars`:

```hcl
subscription_id     = "YOUR_SUBSCRIPTION_ID"
resource_group_name = "rg-api-mgt"
location            = "eastus"
environment         = "dev"
```

#### 3. Deploy

```bash
# Navigate to infrastructure directory
cd infra

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

#### 4. Get Resource Group Details

```bash
terraform output resource_group_name
terraform output resource_group_id
terraform output location
```

### GitHub Actions Deployment

#### 1. Create Azure Service Principal

```bash
az ad sp create-for-rbac \
  --name "github-api-mgt-sp" \
  --role Contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID
```

Output will be:

```json
{
  "appId": "CLIENT_ID",
  "displayName": "github-api-mgt-sp",
  "password": "CLIENT_SECRET",
  "tenant": "TENANT_ID"
}
```

#### 2. Add GitHub Secrets

Go to: **Repository Settings** → **Secrets and variables** → **Actions**

Add these secrets:

- `AZURE_CLIENT_ID` = appId
- `AZURE_CLIENT_SECRET` = password
- `AZURE_TENANT_ID` = tenant
- `AZURE_SUBSCRIPTION_ID` = Your subscription ID

#### 3. Push to Main Branch

The workflow will automatically run:

```bash
git add .
git commit -m "Deploy resource group"
git push origin main
```

Check **Actions** tab to see deployment progress.

## 📊 Workflow Steps

1. **Terraform Validate** - Checks syntax and structure
2. **Terraform Plan** - Shows what will be created
3. **Terraform Apply** - Creates the resource group
4. **Get Outputs** - Displays resource group details

## 🛠️ Management

### View Deployment

```bash
# List all resources
az group show --name rg-api-mgt

# List resources in group
az resource list --resource-group rg-api-mgt
```

### Update Configuration

Edit `infra/terraform.tfvars` and push:

```bash
git add infra/terraform.tfvars
git commit -m "Update resource group settings"
git push origin main
```

GitHub Actions will automatically re-deploy.

### Destroy Resources

```bash
cd infra
terraform destroy
```

Or via GitHub Actions by running manually and destroying.

## 📝 Next Steps

After resource group is created:

1. **Deploy App Service Plan**

   ```bash
   # In your app repository
   az appservice plan create \
     --name app-plan \
     --resource-group rg-api-mgt \
     --sku B1 \
     --is-linux
   ```

2. **Deploy Web Application**

   ```bash
   az webapp create \
     --name myapp \
     --resource-group rg-api-mgt \
     --plan app-plan \
     --runtime "JAVA|17-java17"
   ```

3. **Configure Application Settings**
   ```bash
   az webapp config appsettings set \
     --resource-group rg-api-mgt \
     --name myapp \
     --settings WEBSITES_PORT=8080
   ```

## ❌ Troubleshooting

**Azure Login Failed**

```bash
az login
az account set --subscription YOUR_SUBSCRIPTION_ID
```

**Service Principal Issues**

```bash
# Verify credentials
az login --service-principal \
  --username CLIENT_ID \
  --password CLIENT_SECRET \
  --tenant TENANT_ID
```

**Terraform State Error**

```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

**Resource Group Already Exists**

```bash
# Import existing resource group
terraform import azurerm_resource_group.main /subscriptions/SUB_ID/resourceGroups/rg-api-mgt
```

**GitHub Actions Fails**

- Check **Actions** tab for error logs
- Verify all 4 secrets are set correctly
- Ensure service principal has Contributor role

## 📖 Workflow File

The workflow is defined in: `.github/workflows/eventhub-api-service-deploy.yml`

Key triggers:

- Push to `main` branch → Auto deploy
- Pull Request → Plan only
- Manual trigger → Run workflow

## 🔐 Security Best Practices

1. ✅ Never commit secrets to Git
2. ✅ Use GitHub Secrets for sensitive data
3. ✅ Rotate service principal credentials regularly
4. ✅ Limit service principal scope to specific subscription
5. ✅ Use RBAC roles with least privilege

## 📞 Support

For issues:

1. Check GitHub Actions logs
2. Review Terraform output
3. Check Azure Portal resource group status
4. Verify Azure CLI authentication

```
AZURE_CREDENTIALS        = <entire output from service principal creation>
AZURE_SUBSCRIPTION_ID    = YOUR_SUBSCRIPTION_ID
AZURE_RESOURCE_GROUP_BACKEND = rg-terraform-state
AZURE_STORAGE_ACCOUNT_BACKEND = YOUR_STORAGE_ACCOUNT
```

#### 3. Trigger Deployment

Push to the `main` branch:

```bash
git add .
git commit -m "Deploy infrastructure"
git push origin main
```

Or manually trigger:

```bash
gh workflow run deploy.yml -f environment=dev
```

## 📁 Project Structure

```
azu-infra-setup/
├── .github/
│   └── workflows/
│       └── deploy.yml           # GitHub Actions workflow
├── infra/
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   ├── terraform.tfvars         # Default values
│   └── .gitignore               # Terraform ignore patterns
├── scripts/
│   ├── setup-backend.sh         # Backend setup script
│   └── setup-secrets.sh         # GitHub secrets setup
├── docs/
│   ├── RBAC.md                  # RBAC configuration details
│   └── TROUBLESHOOTING.md       # Troubleshooting guide
├── .github/
│   └── workflows/
│       └── deploy.yml           # CI/CD pipeline
├── README.md                    # This file
└── .gitignore                   # Git ignore patterns
```

## 🔐 RBAC Configuration

The deployment automatically assigns a **Contributor** role to the App Service's managed identity at the resource group scope.

### Role Assignment Details

- **Principal**: App Service Managed Identity
- **Role**: Contributor (customizable via `rbac_role_name` variable)
- **Scope**: Resource Group
- **Type**: Built-in role

### Available Roles

- `Reader` - Read-only access
- `Contributor` - Full access except RBAC management
- `Owner` - Full access including RBAC management
- `Storage Blob Data Contributor` - Blob storage access

To use a different role, modify `terraform.tfvars`:

```hcl
rbac_role_name = "Storage Blob Data Contributor"
```

## 🔍 Outputs

After deployment, Terraform outputs:

```
resource_group_id          = Resource Group ID
resource_group_name        = Resource Group Name
app_service_id             = App Service ID
app_service_name           = App Service Name
app_service_url            = HTTPS URL to the App Service
app_service_principal_id   = Managed Identity Principal ID
service_plan_id            = App Service Plan ID
rbac_role_assignment_id    = RBAC Assignment ID
```

Access outputs:

```bash
cd infra
terraform output app_service_url
```

## 🔧 Customization

### Change App Service SKU

Edit `terraform.tfvars`:

```hcl
app_service_sku = "S1"  # Basic, Standard, or Premium
```

Available SKUs: `B1`, `B2`, `B3`, `S1`, `S2`, `S3`, `P1V2`, `P2V2`, `P3V2`

### Use Custom Docker Image

```hcl
docker_image_name = "myregistry.azurecr.io/myapp:latest"
docker_registry_url = "https://myregistry.azurecr.io"
```

### Enable Diagnostics

```hcl
enable_diagnostics = true
log_analytics_workspace_id = "/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/myWorkspace"
```

### Add Custom App Settings

```hcl
app_settings = {
  "WEBSITE_NODE_DEFAULT_VERSION" = "18-lts"
  "ENVIRONMENT" = "production"
  "DATABASE_URL" = "your-db-connection"
}
```

## 📊 Monitoring & Logging

View deployment logs:

```bash
# Local logs
terraform apply -lock=false -input=false -auto-approve

# GitHub Actions logs
# Go to Actions tab in your GitHub repository
```

## 🧹 Cleanup

To destroy all resources:

```bash
cd infra
terraform destroy \
  -var="subscription_id=YOUR_SUBSCRIPTION_ID" \
  -var-file="terraform.tfvars"
```

**⚠️ Warning**: This will delete all resources including the App Service.

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🐛 Troubleshooting

### Terraform State Lock

If you get a state lock error:

```bash
cd infra
terraform force-unlock LOCK_ID
```

### Azure Authentication Failures

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription YOUR_SUBSCRIPTION_ID

# Verify credentials
az account show
```

### GitHub Actions Failures

Check `.github/workflows/deploy.yml` and GitHub Actions logs for details.

Common issues:

- Invalid Azure credentials
- Missing GitHub secrets
- Insufficient permissions
- Network connectivity issues

## 📝 License

MIT License

## 👥 Contributing

1. Create a feature branch
2. Make changes
3. Submit a pull request

## 📧 Support

For issues and questions, please create a GitHub issue or contact the maintainers.
