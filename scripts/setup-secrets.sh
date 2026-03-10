#!/bin/bash

# GitHub Secrets Setup Script
# This script configures all necessary GitHub secrets for the deployment

set -e

echo "🔐 GitHub Secrets Setup"
echo "======================="

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI is not installed. Please install it from https://cli.github.com"
    exit 1
fi

# Get repository information
REPO=$(gh repo view --json nameWithOwner -q)
echo "📍 Repository: $REPO"

# Authenticate with Azure
echo ""
echo "🔑 Authenticating with Azure..."
read -p "Enter your Azure Subscription ID: " SUBSCRIPTION_ID

# Create service principal
echo ""
echo "🔑 Creating Azure Service Principal..."
read -p "Enter Service Principal name (e.g., github-actions-sp): " SP_NAME

SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID)

echo ""
echo "✅ Service Principal created!"

# Extract values
CLIENT_ID=$(echo $SP_OUTPUT | jq -r '.clientId')
CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r '.clientSecret')
TENANT_ID=$(echo $SP_OUTPUT | jq -r '.tenantId')

# Create Terraform backend storage account
echo ""
echo "📦 Setting up Terraform Backend..."
BACKEND_RG="rg-terraform-state"
BACKEND_SA="tfstate$(shuf -i 10000-99999 -n 1)"

az group create --name $BACKEND_RG --location eastus
az storage account create \
  --resource-group $BACKEND_RG \
  --name $BACKEND_SA \
  --sku Standard_LRS \
  --kind StorageAccountV2

az storage container create \
  --name tfstate \
  --account-name $BACKEND_SA

BACKEND_SA_KEY=$(az storage account keys list \
  --account-name $BACKEND_SA \
  --resource-group $BACKEND_RG \
  --query [0].value -o tsv)

echo "✅ Terraform Backend created!"
echo "   Storage Account: $BACKEND_SA"
echo "   Resource Group: $BACKEND_RG"

# Set GitHub secrets
echo ""
echo "🔐 Setting GitHub Secrets..."

gh secret set AZURE_SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID"
gh secret set AZURE_CLIENT_ID --body "$CLIENT_ID"
gh secret set AZURE_CLIENT_SECRET --body "$CLIENT_SECRET"
gh secret set AZURE_TENANT_ID --body "$TENANT_ID"
gh secret set AZURE_RESOURCE_GROUP_BACKEND --body "$BACKEND_RG"
gh secret set AZURE_STORAGE_ACCOUNT_BACKEND --body "$BACKEND_SA"

# Create AZURE_CREDENTIALS
CREDENTIALS=$(cat <<EOF
{
  "clientId": "$CLIENT_ID",
  "clientSecret": "$CLIENT_SECRET",
  "subscriptionId": "$SUBSCRIPTION_ID",
  "tenantId": "$TENANT_ID"
}
EOF
)

gh secret set AZURE_CREDENTIALS --body "$CREDENTIALS"

echo ""
echo "✅ All GitHub Secrets configured!"
echo ""
echo "📋 Secrets created:"
echo "   - AZURE_SUBSCRIPTION_ID"
echo "   - AZURE_CLIENT_ID"
echo "   - AZURE_CLIENT_SECRET"
echo "   - AZURE_TENANT_ID"
echo "   - AZURE_CREDENTIALS"
echo "   - AZURE_RESOURCE_GROUP_BACKEND"
echo "   - AZURE_STORAGE_ACCOUNT_BACKEND"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update infra/terraform.tfvars with your values"
echo "2. Push changes to main branch"
echo "3. GitHub Actions will automatically deploy"
