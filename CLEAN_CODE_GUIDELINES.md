# Clean Code Guidelines

## Overview

This document outlines the clean code principles and practices used in the EventHub API Service project. Follow these guidelines when contributing to or extending the application.

## 1. Architecture & Design Patterns

### Package Organization

```
com.codex
├── config/        - Spring configuration and beans
├── constant/      - Static constants and enumerations
├── controller/    - REST API endpoints
├── dto/           - Data Transfer Objects
├── exception/     - Custom exceptions
├── service/       - Business logic interfaces
│   └── impl/      - Service implementations
├── util/          - Utility and helper classes
└── entity/        - JPA entities (future)
```

### Layered Architecture

- **HTTP Layer**: Controllers handle HTTP requests/responses
- **Business Logic Layer**: Services contain core business logic
- **Data Access Layer**: Repositories handle data persistence (future)
- **Configuration Layer**: Centralized configuration management

## 2. Naming Conventions

### Classes

- **Controllers**: `*Controller` (e.g., `ResourceController`)
- **Services**: `*Service` interface, `*ServiceImpl` implementation
- **DTOs**: `*Dto` or `*Request*Dto`, `*Response*Dto`
- **Exceptions**: `*Exception` (e.g., `ResourceNotFoundException`)
- **Utilities**: `*Util` (e.g., `LoggingUtil`)

### Methods

- **Creating**: `create*()`, `build*()`
- **Reading**: `get*()`, `find*()`
- **Updating**: `update*()`
- **Deleting**: `delete*()`, `remove*()`
- **Checking**: `is*()`, `has*()`, `exists*()`
- **Validation**: `validate*()`

### Variables

- Use descriptive names: `numberOfUsers` not `n`
- Boolean variables: `isActive`, `hasPermission`
- Collections: `users` not `userList` (use generic Collection types)

## 3. Method Design

### Single Responsibility Principle

Each method should do one thing well:

```java
// ❌ BAD: Multiple responsibilities
public void processAndSave(User user) {
    validateUser(user);
    transformUser(user);
    encryptPassword(user);
    save(user);
    notifyAdmin(user);
}

// ✅ GOOD: Single responsibility
public void createUser(User user) {
    validateUser(user);
    userRepository.save(user);
}
```

### Method Length

- Keep methods focused and concise (ideally under 20 lines)
- Extract complexity into separate methods
- Use meaningful method names that describe intent

### Method Parameters

- Limit parameters to 3-4 maximum
- Use objects/DTOs for multiple related parameters
- Mark required parameters with `@NotNull`

```java
// ❌ BAD: Too many parameters
public void createUser(String name, String email, String phone,
                      String address, String city, String state) {}

// ✅ GOOD: Use DTO
public void createUser(CreateUserRequestDto request) {}
```

## 4. Code Commenting & Documentation

### JavaDoc

Document public methods, classes, and important private methods:

```java
/**
 * Retrieves a user by their unique identifier.
 *
 * @param userId the unique identifier of the user
 * @return the User object if found
 * @throws ResourceNotFoundException if user is not found
 */
public User getUserById(String userId) {
    // implementation
}
```

### Inline Comments

- Explain the "why", not the "what"
- Keep comments concise and accurate

```java
// ✅ GOOD: Explains why
// Lock table to prevent concurrent modifications
tableService.lock();

// ❌ BAD: Obvious from code
// Get the user ID
String userId = user.getId();
```

### Class Documentation

```java
/**
 * REST Controller for resource management endpoints.
 * Provides CRUD operations for resource management.
 *
 * API base path: /api/v1/resources
 */
@RestController
@RequestMapping(ApiConstants.API_PREFIX + "/resources")
public class ResourceController {
}
```

## 5. Error Handling

### Exception Hierarchy

```
Exception
├── ApplicationException (custom base)
│   ├── ResourceNotFoundException
│   ├── ValidationException
│   └── [other custom exceptions]
```

### Exception Usage

- Use specific exceptions, not generic `Exception`
- Include meaningful error messages
- Provide error codes for client handling

```java
// ✅ GOOD
throw new ResourceNotFoundException(
    "User not found with ID: " + userId
);

// ❌ BAD
throw new Exception("Error");
```

### Global Exception Handler

- Centralized in `GlobalExceptionHandler`
- Maps exceptions to appropriate HTTP status codes
- Provides consistent error response format

## 6. Validation

### Input Validation

Use Spring's validation annotations:

```java
@Data
public class CreateResourceRequestDto {
    @NotBlank(message = "Name is required")
    @Size(min = 1, max = 100)
    private String name;

    @Email(message = "Email should be valid")
    private String email;
}
```

### Validation Utility

Use `ValidationUtil` for programmatic validation:

```java
ValidationUtil.validateNotEmpty(name, "name");
ValidationUtil.validateMinimum(age, 18, "age");
```

## 7. Logging Best Practices

### Use Appropriate Log Levels

- **DEBUG**: Detailed flow information (method entry/exit, variable values)
- **INFO**: General application information (startup, important events)
- **WARN**: Warning messages (potentially harmful situations)
- **ERROR**: Error messages (error events with potential recovery)

### Logging Examples

```java
@Slf4j
public class UserService {

    public User createUser(UserDto dto) {
        log.info("Creating user with email: {}", dto.getEmail());

        try {
            User user = mapDtoToUser(dto);
            log.debug("User mapped successfully");

            User saved = userRepository.save(user);
            log.info("User created successfully with ID: {}", saved.getId());

            return saved;
        } catch (Exception ex) {
            log.error("Error creating user", ex);
            throw new ApplicationException("Failed to create user", "USER_CREATION_FAILED");
        }
    }
}
```

### Avoid

- Logging sensitive data (passwords, tokens, SSNs)
- Excessive logging in loops
- Logging in catch blocks without re-throwing or handling

## 8. Testing Guidelines

### Test Structure

```
class TestClass {
    @BeforeEach
    public void setUp() {
        // Initialize test data and mocks
    }

    @Test
    public void should<Expected>When<Condition>() {
        // Given: Set up test data
        // When: Perform action
        // Then: Assert expected outcome
    }
}
```

### Test Naming

- Descriptive names indicating what is being tested
- Format: `test<MethodName><Condition>`

```java
@Test
public void testCreateUserWithValidInput() { }

@Test
public void testGetUserNotFoundThrowsException() { }

@Test
public void testUpdateUserPartialFieldsSucceeds() { }
```

### Mocking

```java
@MockBean
private UserRepository userRepository;

@BeforeEach
public void setUp() {
    when(userRepository.findById("123"))
        .thenReturn(Optional.of(testUser));
}
```

### Coverage

- Aim for 80%+ code coverage
- Test happy paths and edge cases
- Test error scenarios

## 9. Constants Management

### Use ApiConstants Class

```java
// ✅ GOOD: Centralized constants
@GetMapping(ApiConstants.API_PREFIX + ApiConstants.HEALTH_ENDPOINT)
public ResponseEntity<ApiResponse<HealthCheckResponseDto>> getHealth() {
}

// ❌ BAD: Magic strings
@GetMapping("/api/v1/health")
public ResponseEntity<ApiResponse<HealthCheckResponseDto>> getHealth() {
}
```

## 10. REST API Design

### HTTP Methods

- **GET**: Retrieve resources (safe, idempotent)
- **POST**: Create new resources
- **PUT**: Update entire resource
- **PATCH**: Partial update
- **DELETE**: Remove resources

### Status Codes

- **200**: OK (successful GET, PUT, PATCH)
- **201**: Created (successful POST)
- **204**: No Content (successful DELETE)
- **400**: Bad Request (validation errors)
- **404**: Not Found
- **500**: Internal Server Error

### Response Consistency

```json
{
  "status": "SUCCESS|ERROR|VALIDATION_ERROR",
  "message": "Human-readable message",
  "data": {
    // Response payload
  },
  "timestamp": "2026-03-11T10:30:00",
  "errorCode": "ERROR_CODE"
}
```

## 11. Dependency Injection

### Constructor Injection (Preferred)

```java
@Service
public class UserService {
    private final UserRepository userRepository;

    // ✅ GOOD: Constructor injection
    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

### Field Injection (Avoid)

```java
// ❌ NOT RECOMMENDED
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
}
```

## 12. Code Review Checklist

- [ ] Code follows naming conventions
- [ ] Methods are concise and single-responsibility
- [ ] Error handling is appropriate
- [ ] Logging is adequate (not excessive)
- [ ] Input validation is present
- [ ] Unit tests exist with good coverage
- [ ] JavaDoc comments on public methods
- [ ] No hardcoded strings (use constants)
- [ ] No commented-out code
- [ ] No console.log or System.out.println

## 13. Performance Considerations

- Use lazy loading for collections
- Avoid N+1 query problems
- Cache frequently accessed data
- Use pagination for large result sets
- Profile code for bottlenecks

## 14. Security Best Practices

- Validate all input
- Sanitize output
- Use parameterized queries (JPA handles this)
- Don't log sensitive information
- Use encryption for sensitive data
- Implement proper authentication/authorization
- Use HTTPS in production
- Keep dependencies updated

## 15. Common Pitfalls to Avoid

1. **Violating DRY (Don't Repeat Yourself)**
   - Extract repeated code into methods or utilities

2. **God Classes**
   - Classes doing too much
   - Solution: Break into smaller, focused classes

3. **Magic Numbers**
   - Use constants for all hardcoded values

4. **Null Pointer Exceptions**
   - Use Optional or null checks
   - Use @NotNull/@Nullable annotations

5. **Overuse of Static**
   - Preferably avoid static methods in services
   - Use dependency injection instead

6. **Overly Complex Logic**
   - Break complex logic into smaller methods
   - Extract to utility classes

---

## References

- Clean Code by Robert C. Martin
- Spring Boot Best Practices
- Clean Architecture by Robert C. Martin
- Java Concurrency in Practice

**Version**: 1.0
**Last Updated**: March 11, 2026
