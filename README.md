# Event Hub API Service - Spring Boot on Azure

**Simple Terraform setup for Spring Boot + Event Hub on Azure App Service**

## What Gets Created

```
Resource Group
├── App Service Plan (Linux)
├── App Service (Spring Boot - Java 17)
├── Event Hub Namespace
├── Event Hub
└── RBAC (managed identity can send/receive events)
```

## 📁 Files (Just 4!)

| File                     | Purpose                                  |
| ------------------------ | ---------------------------------------- |
| `infra/main.tf`          | Resources (App Service, Event Hub, RBAC) |
| `infra/variables.tf`     | Configuration inputs                     |
| `infra/outputs.tf`       | Deployment outputs                       |
| `infra/terraform.tfvars` | Your settings                            |

**That's it.** ~100 lines of Terraform. No CI/CD pipelines.

## 🚀 Quick Deploy (5 minutes)

### 1. Update config

Edit `infra/terraform.tfvars`:

```hcl
subscription_id     = "YOUR_SUBSCRIPTION_ID"  # See below
app_name            = "eventhub-api"
resource_group_name = "rg-eventhub-api"
location            = "eastus"
app_service_sku     = "B1"  # B1, B2, S1, S2, P1V2, etc
enable_eventhub     = true
```

### 2. Get Subscription ID

```bash
az login
az account show --query id -o tsv
```

### 3. Deploy

```bash
cd infra
terraform init
terraform apply
```

### 4. Get your app URL

```bash
terraform output app_service_url
```

**Done!** Your Spring Boot app is live.

## � Spring Boot + Event Hub Code

Your app gets **managed identity** automatically. Use it to connect to Event Hub.

### Maven Dependency

Add to `pom.xml`:

```xml
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-messaging-eventhubs</artifactId>
    <version>5.18.0</version>
</dependency>
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-identity</artifactId>
    <version>1.11.0</version>
</dependency>
```

### Java Service

```java
import com.azure.identity.DefaultAzureCredential;
import com.azure.messaging.eventhubs.EventHubClientBuilder;
import com.azure.messaging.eventhubs.EventHubProducerClient;
import com.azure.messaging.eventhubs.models.EventData;
import java.net.URI;
import org.springframework.stereotype.Service;

@Service
public class EventService {
    private static final String NAMESPACE = "evhns-eventhub-api.servicebus.windows.net";
    private static final String EVENT_HUB = "evh-eventhub-api";

    public void sendEvent(String message) {
        EventHubProducerClient producer = new EventHubClientBuilder()
            .credential(new DefaultAzureCredential(),
                new URI("sb://" + NAMESPACE))
            .eventHubName(EVENT_HUB)
            .buildProducerClient();

        producer.send(new EventData(message));
        producer.close();
    }
}
```

### REST Controller

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/events")
public class EventController {

    @Autowired
    private EventService eventService;

    @PostMapping
    public String sendEvent(@RequestBody String message) {
        eventService.sendEvent(message);
        return "Event sent: " + message;
    }
}
```

## 🛠️ Management Commands

```bash
# View deployment plan
cd infra && terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# View app URL
terraform output app_service_url

# Check logs
az webapp log tail --resource-group rg-eventhub-api --name app-eventhub-api

# Clean up (destroys everything)
terraform destroy
```

## 🔧 Customization

**Change app size:**

```hcl
app_service_sku = "S1"  # Larger: S1, S2, P1V2
```

**Different Azure region:**

```hcl
location = "westus"  # Or any region
```

**Disable Event Hub (just App Service):**

```hcl
enable_eventhub = false
```

**Different Java version:**
Edit `infra/main.tf` and change `java_version` variable.

## ❌ Troubleshooting

**App not running?**

```bash
az webapp log tail --resource-group rg-eventhub-api --name app-eventhub-api
```

**Event Hub connection fails?**

- Managed identity roles are auto-assigned, no action needed
- Verify app is deployedusing above command

**Auth errors?**

```bash
az login
az account set --subscription YOUR_SUBSCRIPTION_ID
```

**Terraform state issues?**

```bash
rm -rf infra/.terraform infra/.terraform.lock.hcl
terraform init
```

---

**Setup time**: ~10 minutes | **Lines of code**: ~100 | **Complexity**: ✅ Beginner-friendly
