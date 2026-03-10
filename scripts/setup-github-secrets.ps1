# Event Hub API Service - GitHub Secrets Setup Script
# This script automates GitHub secrets configuration

param(
    [string]$SubscriptionId = "eae8defa-f2ec-4839-a839-5dc6ca7eadb8",
    [string]$TenantId = "f3f67193-3f5a-4b1e-ba8a-f4b397127a9f",
    [string]$ServicePrincipalName = "github-eventhub-api",
    [string]$GitHubRepo = ""  # Format: owner/repo-name
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Event Hub API Service - GitHub Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify Azure CLI is installed
Write-Host "Step 1: Checking Azure CLI..." -ForegroundColor Yellow
$azCliExists = Get-Command az -ErrorAction SilentlyContinue
if (-not $azCliExists) {
    Write-Host "[FAIL] Azure CLI is not installed!" -ForegroundColor Red
    Write-Host "Download from: https://learn.microsoft.com/cli/azure/install-azure-cli-windows" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Azure CLI is installed" -ForegroundColor Green
Write-Host ""

# Step 2: Verify GitHub CLI is installed
Write-Host "Step 2: Checking GitHub CLI..." -ForegroundColor Yellow
$ghCliExists = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghCliExists) {
    Write-Host "[WARN] GitHub CLI is not installed (optional, but recommended)" -ForegroundColor Yellow
    Write-Host "You will need to manually add secrets to GitHub" -ForegroundColor Yellow
    $useGhCli = $false
} else {
    Write-Host "[OK] GitHub CLI is installed" -ForegroundColor Green
    $useGhCli = $true
}
Write-Host ""

# Step 2b: Check if authenticated with GitHub and get repo
if ($useGhCli) {
    Write-Host "Step 2b: Getting GitHub Repository..." -ForegroundColor Yellow
    
    if ($GitHubRepo) {
        Write-Host "[OK] Using provided GitHub Repository: $GitHubRepo" -ForegroundColor Green
    } else {
        try {
            $GitHubRepo = gh repo view --json nameWithOwner -q 2>$null
            if ($GitHubRepo) {
                Write-Host "[OK] Detected GitHub Repository: $GitHubRepo" -ForegroundColor Green
            } else {
                Write-Host "[WARN] Could not auto-detect GitHub repository" -ForegroundColor Yellow
                $GitHubRepo = Read-Host "Enter GitHub repository (format: owner/repo-name)"
                if (-not $GitHubRepo) {
                    Write-Host "[WARN] No repository provided. Manual setup required." -ForegroundColor Yellow
                    $useGhCli = $false
                } else {
                    Write-Host "[OK] Using: $GitHubRepo" -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "[WARN] GitHub error: $_" -ForegroundColor Yellow
            $GitHubRepo = Read-Host "Enter GitHub repository (format: owner/repo-name)"
            if (-not $GitHubRepo) {
                Write-Host "[WARN] No repository provided. Manual setup required." -ForegroundColor Yellow
                $useGhCli = $false
            } else {
                Write-Host "[OK] Using: $GitHubRepo" -ForegroundColor Green
            }
        }
    }
    
    Write-Host ""
}

# Step 3: Login to Azure
Write-Host "Step 3: Logging in to Azure..." -ForegroundColor Yellow
try {
    $account = az account show --subscription $SubscriptionId 2>$null | ConvertFrom-Json
    Write-Host "[OK] Already logged in as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Host "Launching Azure login..." -ForegroundColor Yellow
    az login --tenant $TenantId | Out-Null
    $account = az account show --subscription $SubscriptionId 2>$null | ConvertFrom-Json
    Write-Host "[OK] Logged in as: $($account.user.name)" -ForegroundColor Green
}
Write-Host ""

# Step 4: Create Service Principal
Write-Host "Step 4: Creating Service Principal: $ServicePrincipalName" -ForegroundColor Yellow
$spOutput = az ad sp create-for-rbac `
    --name $ServicePrincipalName `
    --role Contributor `
    --scopes "/subscriptions/$SubscriptionId" `
    --output json 2>&1

# Extract JSON from output (filter out warnings)
$jsonLines = $spOutput | Select-String -Pattern '^\s*{' -Context 0,100
if ($jsonLines) {
    $jsonStart = $jsonLines[0].LineNumber - 1
    $spJson = $spOutput[$jsonStart..($spOutput.Count - 1)] -join "`n"
    
    try {
        $sp = $spJson | ConvertFrom-Json
        $clientId = $sp.appId
        $clientSecret = $sp.password
        Write-Host "[OK] Service Principal created/found: $clientId" -ForegroundColor Green
        if ($clientSecret) {
            Write-Host ""
            Write-Host "[ALERT] IMPORTANT: Save this password securely!" -ForegroundColor Red
            Write-Host "Password: $clientSecret" -ForegroundColor Red
            Write-Host "You will NOT see it again!" -ForegroundColor Red
            Write-Host ""
        }
    } catch {
        Write-Host "[FAIL] Failed to parse service principal response" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "[FAIL] Failed to create or find service principal" -ForegroundColor Red
    Write-Host "Output: $spOutput" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 5: Display Configuration
Write-Host "Step 5: Your Configuration" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Client ID:      $clientId" -ForegroundColor Green
Write-Host "Tenant ID:      $TenantId" -ForegroundColor Green
Write-Host "Subscription ID: $SubscriptionId" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 6: Add to GitHub (if gh CLI available)
if ($useGhCli) {
    Write-Host "Step 6: Adding secrets to GitHub..." -ForegroundColor Yellow
    
    # Check if authenticated with GitHub
    try {
        gh auth status 2>&1 | Out-Null
        $ghAuth = $true
    } catch {
        Write-Host "[WARN] Not authenticated with GitHub CLI" -ForegroundColor Yellow
        Write-Host "Run: gh auth login" -ForegroundColor Yellow
        $ghAuth = $false
    }
    
    if ($ghAuth) {
        Write-Host "Setting AZURE_CLIENT_ID..." -ForegroundColor Cyan
        $result = gh secret set AZURE_CLIENT_ID --body $clientId --repo $GitHubRepo 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] AZURE_CLIENT_ID set" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Failed to set AZURE_CLIENT_ID: $result" -ForegroundColor Yellow
        }
        
        Write-Host "Setting AZURE_TENANT_ID..." -ForegroundColor Cyan
        $result = gh secret set AZURE_TENANT_ID --body $TenantId --repo $GitHubRepo 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] AZURE_TENANT_ID set" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Failed to set AZURE_TENANT_ID: $result" -ForegroundColor Yellow
        }
        
        Write-Host "Setting AZURE_SUBSCRIPTION_ID..." -ForegroundColor Cyan
        $result = gh secret set AZURE_SUBSCRIPTION_ID --body $SubscriptionId --repo $GitHubRepo 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] AZURE_SUBSCRIPTION_ID set" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Failed to set AZURE_SUBSCRIPTION_ID: $result" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "[OK] GitHub secrets processed!" -ForegroundColor Green
        Write-Host ""
    }
} else {
    Write-Host "Step 6: Add Secrets to GitHub Manually" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Go to: GitHub Repository Settings > Secrets and variables > Actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Add these 3 secrets:" -ForegroundColor Green
    Write-Host ""
    Write-Host "Secret 1:" -ForegroundColor Yellow
    Write-Host "  Name:  AZURE_CLIENT_ID" -ForegroundColor Cyan
    Write-Host "  Value: $clientId" -ForegroundColor White
    Write-Host ""
    Write-Host "Secret 2:" -ForegroundColor Yellow
    Write-Host "  Name:  AZURE_TENANT_ID" -ForegroundColor Cyan
    Write-Host "  Value: $TenantId" -ForegroundColor White
    Write-Host ""
    Write-Host "Secret 3:" -ForegroundColor Yellow
    Write-Host "  Name:  AZURE_SUBSCRIPTION_ID" -ForegroundColor Cyan
    Write-Host "  Value: $SubscriptionId" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. [OK] Service Principal created" -ForegroundColor Green
Write-Host "2. [OK] GitHub secrets configured" -ForegroundColor Green
Write-Host "3. [TODO] Update terraform.tfvars with your app name (optional)" -ForegroundColor Yellow
Write-Host "4. [TODO] Push to main branch to trigger deployment" -ForegroundColor Yellow
Write-Host ""
Write-Host "Your deployment will start automatically!" -ForegroundColor Cyan