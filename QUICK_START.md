# Quick Start - Deploy Event Hub API Service

Your subscription details are confirmed:

- **Subscription ID**: eae8defa-f2ec-4839-a839-5dc6ca7eadb8
- **Tenant ID**: f3f67193-3f5a-4b1e-ba8a-f4b397127a9f
- **Subscription Name**: e2e-sub
- **Your Role**: Owner ✅

## ⚡ Automated Setup (30 seconds)

### Option 1: Use PowerShell Script (Easiest)

```powershell
# 1. Open PowerShell as Administrator
# 2. Navigate to project
cd c:\Users\sagar\development\API_SERVICES\azu-infra-setup

# 3. Run setup script
.\scripts\setup-github-secrets.ps1

# That's it! The script will:
# ✅ Create service principal automatically
# ✅ Add GitHub secrets automatically
# ✅ Show deployment status
```

### Option 2: Manual Setup (If script doesn't work)

```bash
# 1. Create service principal
az ad sp create-for-rbac `
  --name "github-eventhub-api" `
  --role Contributor `
  --scopes "/subscriptions/eae8defa-f2ec-4839-a839-5dc6ca7eadb8"

# 2. Save the output:
#    - appId = AZURE_CLIENT_ID
#    - tenant = AZURE_TENANT_ID (f3f67193-3f5a-4b1e-ba8a-f4b397127a9f)
#    - password = Save securely (not used in GitHub)

# 3. Add to GitHub Secrets:
#    - AZURE_CLIENT_ID = <appId>
#    - AZURE_TENANT_ID = f3f67193-3f5a-4b1e-ba8a-f4b397127a9f
#    - AZURE_SUBSCRIPTION_ID = eae8defa-f2ec-4839-a839-5dc6ca7eadb8
```

## 🚀 After Setup

### 1. Verify Secrets Are Added

Go to: **GitHub Repository → Settings → Secrets and variables → Actions**

You should see 3 secrets:

- ✅ AZURE_CLIENT_ID
- ✅ AZURE_TENANT_ID
- ✅ AZURE_SUBSCRIPTION_ID

### 2. Trigger Deployment

```bash
# Option A: Push to main branch
git add .
git commit -m "Deploy Event Hub API Service"
git push origin main

# Option B: Manual trigger in GitHub Actions
# Go to: Actions tab → Workflows → Click "Run workflow"
```

### 3. Watch Deployment

- Go to **GitHub Actions** tab
- Click on the running workflow
- Watch the progress in real-time
- Status will show:
  - ✅ Validate Terraform
  - ✅ Plan Deployment
  - ✅ Apply Deployment
  - ✅ Verify Deployment

### 4. Get Your App URL

After deployment completes:

- Go to **Workflow Run → Apply Deployment → Get Outputs**
- Copy the **App Service URL** (e.g., `https://app-eventhub-api.azurewebsites.net`)

## 📊 What Gets Deployed

```
✅ Resource Group: rg-eventhub-api
✅ App Service: app-eventhub-api
✅ App Service Plan: asp-eventhub-api
✅ Event Hub Namespace: evhns-eventhub-api
✅ Event Hub: evh-eventhub-api
✅ RBAC: Managed Identity (auto-configured)
```

## 🔌 Next: Deploy Your Spring Boot App

Once Azure resources are deployed, you can push your Spring Boot application:

```bash
# 1. Build your Spring Boot app
mvn clean package

# 2. Deploy to App Service
az webapp deployment source config-zip \
  --resource-group rg-eventhub-api \
  --name app-eventhub-api \
  --src target/myapp.jar

# Or use GitHub Actions (optional)
```

## ⚠️ Troubleshooting

### "Service Principal already exists"

This is fine! The script will find and use the existing one.

### "GitHub CLI not installed"

Script will show manual steps. Just copy-paste the 3 secrets into GitHub.

### "Deployment failed"

Check workflow logs:

- Go to **Actions → [Failed Workflow] → Logs**
- Look for error details
- Common issues:
  - Invalid subscription ID (verify it matches)
  - Service principal not found (re-run script)
  - GitHub secrets missing (verify all 3 are there)

### "Auth error: SIGN_IN_FAILED"

Your GitHub CLI needs authentication:

```bash
gh auth login
# Follow prompts to authenticate
```

## 📋 Summary

| Step                     | Status         | Time     |
| ------------------------ | -------------- | -------- |
| Create Service Principal | Automated      | <1 min   |
| Add GitHub Secrets       | Automated      | <30 sec  |
| Terraform Deployment     | Auto (on push) | ~3-5 min |
| Spring Boot Deployment   | Manual         | ~1-2 min |

**Total time to production: ~10 minutes** ⏱️

---

**Ready?** Run the script and watch your Event Hub API Service come to life! 🚀
