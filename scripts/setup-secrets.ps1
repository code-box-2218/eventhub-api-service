# GitHub Secrets Setup Script (PowerShell)
# This script configures all necessary GitHub secrets for the deployment

param(
    [string]$SubscriptionId,
    [string]$ServicePrincipalName = "github-actions-sp"
)

Write-Host "🔐 GitHub Secrets Setup" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

# Check if gh CLI is installed
$ghExists = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghExists) {
    Write-Host "❌ GitHub CLI is not installed. Please install it from https://cli.github.com" -ForegroundColor Red
    exit 1
}

# Get repository information
$repo = & gh repo view --json nameWithOwner -q
Write-Host "📍 Repository: $repo" -ForegroundColor Green

# Get subscription ID if not provided
if (-not $SubscriptionId) {
    $SubscriptionId = Read-Host "Enter your Azure Subscription ID"
}

# Create service principal
Write-Host ""
Write-Host "🔑 Creating Azure Service Principal..." -ForegroundColor Cyan

$spOutput = & az ad sp create-for-rbac `
    --name $ServicePrincipalName `
    --role Contributor `
    --scopes "/subscriptions/$SubscriptionId" | ConvertFrom-Json

Write-Host "✅ Service Principal created!" -ForegroundColor Green

# Extract values
$clientId = $spOutput.clientId
$clientSecret = $spOutput.clientSecret
$tenantId = $spOutput.tenantId

# Create Terraform backend storage account
Write-Host ""
Write-Host "📦 Setting up Terraform Backend..." -ForegroundColor Cyan

$backendRG = "rg-terraform-state"
$backendSA = "tfstate$((Get-Random -Minimum 10000 -Maximum 99999))"

& az group create --name $backendRG --location eastus
& az storage account create `
    --resource-group $backendRG `
    --name $backendSA `
    --sku Standard_LRS `
    --kind StorageAccountV2

& az storage container create `
    --name tfstate `
    --account-name $backendSA

$backendSAKey = & az storage account keys list `
    --account-name $backendSA `
    --resource-group $backendRG `
    --query "[0].value" -o tsv

Write-Host "✅ Terraform Backend created!" -ForegroundColor Green
Write-Host "   Storage Account: $backendSA" -ForegroundColor Green
Write-Host "   Resource Group: $backendRG" -ForegroundColor Green

# Set GitHub secrets
Write-Host ""
Write-Host "🔐 Setting GitHub Secrets..." -ForegroundColor Cyan

& gh secret set AZURE_SUBSCRIPTION_ID --body $SubscriptionId
& gh secret set AZURE_CLIENT_ID --body $clientId
& gh secret set AZURE_CLIENT_SECRET --body $clientSecret
& gh secret set AZURE_TENANT_ID --body $tenantId
& gh secret set AZURE_RESOURCE_GROUP_BACKEND --body $backendRG
& gh secret set AZURE_STORAGE_ACCOUNT_BACKEND --body $backendSA

# Create AZURE_CREDENTIALS
$credentials = @{
    clientId       = $clientId
    clientSecret   = $clientSecret
    subscriptionId = $SubscriptionId
    tenantId       = $tenantId
} | ConvertTo-Json

& gh secret set AZURE_CREDENTIALS --body $credentials

Write-Host ""
Write-Host "✅ All GitHub Secrets configured!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Secrets created:" -ForegroundColor Cyan
Write-Host "   - AZURE_SUBSCRIPTION_ID" -ForegroundColor Green
Write-Host "   - AZURE_CLIENT_ID" -ForegroundColor Green
Write-Host "   - AZURE_CLIENT_SECRET" -ForegroundColor Green
Write-Host "   - AZURE_TENANT_ID" -ForegroundColor Green
Write-Host "   - AZURE_CREDENTIALS" -ForegroundColor Green
Write-Host "   - AZURE_RESOURCE_GROUP_BACKEND" -ForegroundColor Green
Write-Host "   - AZURE_STORAGE_ACCOUNT_BACKEND" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update infra/terraform.tfvars with your values" -ForegroundColor Yellow
Write-Host "2. Push changes to main branch" -ForegroundColor Yellow
Write-Host "3. GitHub Actions will automatically deploy" -ForegroundColor Yellow
