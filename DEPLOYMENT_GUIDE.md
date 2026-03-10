# Azure Terraform App Service Deployment

This repository contains Infrastructure-as-Code (IaC) for deploying an Azure App Service with automated RBAC configuration and GitHub Actions CI/CD pipeline.

## 📋 Architecture

```
Azure Resource Group
├── App Service Plan (Linux)
├── App Service (with Managed Identity)
├── RBAC Role Assignment (Contributor)
└── Diagnostic Settings (optional)
```

## 🚀 Quick Start

### Prerequisites

1. **Azure Account** - An active Azure subscription
2. **Terraform** - Version 1.5.0 or later
3. **Azure CLI** - Installed and configured
4. **GitHub Repository** - With Actions enabled

### Local Deployment

#### 1. Initialize Terraform Backend

First, create an Azure Storage Account for Terraform state:

```bash
# Set variables
$resourceGroup = "rg-terraform-state"
$storageAccount = "tfstate$(Get-Random -Minimum 10000 -Maximum 99999)"
$location = "eastus"

# Create resource group and storage account
az group create --name $resourceGroup --location $location
az storage account create \
  --resource-group $resourceGroup \
  --name $storageAccount \
  --sku Standard_LRS \
  --kind StorageAccountV2

# Create container
az storage container create \
  --name tfstate \
  --account-name $storageAccount
```

#### 2. Configure Variables

Edit `infra/terraform.tfvars`:

```hcl
subscription_id          = "YOUR_SUBSCRIPTION_ID"
environment              = "dev"
location                 = "eastus"
app_name                 = "myapp"
resource_group_name      = "rg-myapp-dev"
app_service_sku          = "B1"
app_service_always_on    = false
docker_image_name        = "nginx:latest"
rbac_role_name           = "Contributor"
```

#### 3. Initialize and Deploy

```bash
# Navigate to infrastructure directory
cd infra

# Initialize Terraform
terraform init \
  -backend-config="resource_group_name=rg-terraform-state" \
  -backend-config="storage_account_name=YOUR_STORAGE_ACCOUNT" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=terraform.tfstate"

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

### GitHub Actions Deployment

#### 1. Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role Contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID
```

#### 2. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

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
