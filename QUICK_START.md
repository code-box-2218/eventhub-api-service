# Quick Start Guide - EventHub API Service

## ⚡ Quick Setup (5 minutes)

### Prerequisites

- Java 25 or higher
- Windows 10/11

### Steps

1. **Navigate to project directory**

```bash
cd c:\Users\sagar\development\API_SERVICES\eventhub-api-service
```

2. **Build the project**

```bash
.\mvnw.cmd clean install
```

3. **Run the application**

```bash
.\mvnw.cmd spring-boot:run
```

4. **Access Swagger UI**
   Visit: http://localhost:8080/swagger-ui.html

You'll see interactive Swagger documentation where you can:

- View all API endpoints
- See request/response schemas
- Test APIs directly
- View error codes

---

## 📚 Project Structure Quick Reference

| Folder        | Purpose                                        |
| ------------- | ---------------------------------------------- |
| `controller/` | REST endpoints (with Swagger annotations)      |
| `service/`    | Business logic interfaces & implementations    |
| `dto/`        | API request/response contracts                 |
| `exception/`  | Error handling & custom exceptions             |
| `util/`       | Helper classes (Logging, Validation, Response) |
| `config/`     | Spring configuration                           |
| `constant/`   | Application constants                          |

---

## 🔌 Testing the API

### Using cURL

**Get All Resources**

```bash
curl -X GET http://localhost:8080/api/v1/resources
```

**Create Resource**

```bash
curl -X POST http://localhost:8080/api/v1/resources \
  -H "Content-Type: application/json" \
  -d '{"name":"My Resource","description":"A test resource"}'
```

**Get Resource**

```bash
curl -X GET http://localhost:8080/api/v1/resources/{id}
```

**Update Resource**

```bash
curl -X PUT http://localhost:8080/api/v1/resources/{id} \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Name"}'
```

**Delete Resource**

```bash
curl -X DELETE http://localhost:8080/api/v1/resources/{id}
```

### Using Swagger UI (Recommended)

Visit: http://localhost:8080/swagger-ui.html and use the interactive interface

---

## ⚙️ Configuration

### Change Port

Edit `src/main/resources/application.yml`:

```yaml
server:
  port: 8081
```

### Change Logging Level

Edit `src/main/resources/application.yml`:

```yaml
logging:
  level:
    com.codex: DEBUG # or INFO, WARN, ERROR
```

### Enable/Disable Swagger

```yaml
springdoc:
  swagger-ui:
    enabled: true
```

---

## 🔑 Key Files to Know

| File                          | Purpose                              |
| ----------------------------- | ------------------------------------ |
| `application.yml`             | Main YAML configuration              |
| `pom.xml`                     | Maven dependencies                   |
| `ResourceController.java`     | Example REST controller with Swagger |
| `ResourceService.java`        | Example service interface            |
| `ApiResponse.java`            | Generic response wrapper             |
| `GlobalExceptionHandler.java` | Centralized error handling           |

---

## 🔑 Key Principles to Remember

1. **Always use `@Slf4j`** annotation for logging
2. **Validate inputs** using `@Valid` and `ValidationUtil`
3. **Use DTOs** for all API contracts
4. **Add Swagger annotations** to controllers for documentation
5. **Use `ApiResponse`** wrapper for all responses
6. **Never throw generic Exception** → Use specific exceptions
7. **Keep methods small** → Extract to separate methods
8. **Use constants** → No hardcoded values
9. **Use constructor injection** → Never field injection
10. **Always add JavaDoc** to public methods

---

## ⚠️ Common Issues & Solutions

### Port 8080 Already in Use

Change port in `application.yml` or kill the process:

```bash
netstat -ano | findstr ":8080"
taskkill /PID <PID> /F
```

### Build Fails

```bash
# Clean and force update
.\mvnw.cmd clean install -U
```

### Check Build

```bash
# Verify compilation only
.\mvnw.cmd clean compile
```

---

## 📖 Code Examples

### Adding Swagger to a Controller

```java
@Slf4j
@RestController
@RequestMapping(ApiConstants.API_PREFIX + "/users")
@Tag(name = "User Management", description = "User endpoints")
public class UserController {

    @PostMapping
    @Operation(summary = "Create user", description = "Creates a new user")
    @ApiResponses(value = {
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "201",
            description = "User created"
        ),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "400",
            description = "Invalid input"
        )
    })
    public ResponseEntity<ApiResponse<UserDto>> createUser(
            @Valid @RequestBody CreateUserRequest request) {
        // Implementation
    }
}
```

### Creating a Service

```java
public interface UserService {
    UserDto getUserById(String id);
    UserDto createUser(CreateUserRequest request);
}

@Slf4j
@Service
public class UserServiceImpl implements UserService {
    @Override
    public UserDto getUserById(String id) {
        log.info("Fetching user: {}", id);
        // Implementation
    }
}
```

### Adding Validation

```java
@Data
@Builder
public class CreateUserRequest {
    @NotBlank(message = "Name required")
    @Size(min = 1, max = 100)
    private String name;

    @Email(message = "Valid email required")
    private String email;
}
```

---

## 🚀 Project Files Structure

```
Now has 19 Java source files instead of 22
- Test files:          REMOVED ✓
- Health endpoints:    REMOVED ✓
- Properties files:    MOVED to YAML ✓
- Swagger support:     ADDED ✓
```

---

## 📞 Next Steps

1. **Review existing code patterns** in ResourceController
2. **Create new services** following the established patterns
3. **Add Swagger annotations** to your endpoints
4. **Test via Swagger UI** at http://localhost:8080/swagger-ui.html
5. **Deploy to Azure** when ready

---

**Happy Coding! 🎉**

For detailed information, see README.md and CLEAN_CODE_GUIDELINES.md
