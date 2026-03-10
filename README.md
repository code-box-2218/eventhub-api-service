# EventHub API Service - Clean Code Architecture with Swagger

A production-ready Java Spring Boot REST API application with Swagger/OpenAPI documentation, clean code principles, and modern development practices.

## 🎯 Project Overview

This project showcases:

- **Clean Architecture**: Organized package structure with clear separation of concerns
- **Spring Boot Best Practices**: Dependency injection, configuration management, and lifecycle handling
- **REST API Design**: Proper HTTP methods, status codes, and response structures
- **Swagger/OpenAPI**: Interactive API documentation with Springdoc
- **Input Validation**: Bean validation with custom error handling
- **Exception Handling**: Centralized global exception handler for consistent error responses
- **Service Layer**: Business logic separation from controllers
- **DTOs**: Data transfer objects for API contracts
- **Logging**: Structured logging with SLF4J
- **YAML Configuration**: Profile-based YAML configuration for flexible environment setup

## 🔍 API Documentation

**Access Swagger UI**: http://localhost:8080/swagger-ui.html
**Access OpenAPI JSON**: http://localhost:8080/v3/api-docs

## 📁 Project Structure

```
eventhub-api-service/
├── src/
│   └── main/
│       ├── java/com/codex/
│       │   ├── config/           # Spring configuration beans
│       │   ├── constant/         # Application constants
│       │   ├── controller/       # REST endpoints with Swagger annotations
│       │   ├── dto/              # Data Transfer Objects
│       │   ├── exception/        # Custom exceptions and handlers
│       │   ├── service/          # Business logic interfaces
│       │   │   └── impl/        # Service implementations
│       │   ├── util/             # Utility classes
│       │   └── EventhubApiServiceApplication.java
│       └── resources/
│           └── application.yml   # YAML configuration
├── pom.xml
└── README.md
```

## 🚀 Key Components

### 1. **Controllers** (`controller/`)

RESTful API endpoints with Swagger annotations for automatic documentation.

### 2. **Services** (`service/`)

Business logic layer with clear interfaces and implementations.

### 3. **DTOs** (`dto/`)

Data Transfer Objects for API requests and responses.

### 4. **Exception Handling** (`exception/`)

Centralized global exception handler for consistent error responses.

### 5. **Utilities** (`util/`)

Reusable utility classes (LoggingUtil, ValidationUtil, ResponseUtil).

## 🔧 API Endpoints

### Resources (CRUD Operations)

```
POST   /api/v1/resources              # Create a new resource
GET    /api/v1/resources              # Get all resources
GET    /api/v1/resources/{id}         # Get resource by ID
PUT    /api/v1/resources/{id}         # Update a resource
DELETE /api/v1/resources/{id}         # Delete a resource
```

**View all endpoints and test them at**: http://localhost:8080/swagger-ui.html

## 📝 API Response Format

All endpoints return consistent response structure:

**Success Response** (200 OK):

```json
{
  "status": "SUCCESS",
  "message": "Operation completed successfully",
  "data": {
    "id": "resource-id",
    "name": "Resource Name"
  },
  "timestamp": "2026-03-11T10:30:00"
}
```

**Error Response** (400/404/500):

```json
{
  "status": "ERROR",
  "message": "Resource not found",
  "errorCode": "RESOURCE_NOT_FOUND",
  "timestamp": "2026-03-11T10:30:00"
}
```

**Validation Error** (400):

```json
{
  "status": "VALIDATION_ERROR",
  "message": "Validation failed for the request",
  "errorCode": "VALIDATION_FAILED",
  "data": [
    {
      "field": "name",
      "message": "Name is required",
      "rejectedValue": null
    }
  ],
  "timestamp": "2026-03-11T10:30:00"
}
```

## 🏗️ Clean Code Principles Applied

1. **Single Responsibility Principle**: Each class has one reason to change
2. **Dependency Injection**: Spring manages dependencies
3. **Interface Segregation**: Services defined by focused interfaces
4. **Environment Configuration**: Externalized configuration via YAML
5. **Logging**: Comprehensive logging for debugging and monitoring
6. **Error Handling**: Custom exceptions with meaningful error codes
7. **Validation**: Input validation at controller level
8. **Documentation**: Swagger annotations and JavaDoc comments
9. **Constants**: Centralized configuration constants
10. **Code Organization**: Clean package structure

## ⚙️ Configuration

The application uses YAML-based configuration (`application.yml`) for flexibility:

```yaml
spring:
  application:
    name: eventhub-api-service
  jackson:
    default-property-inclusion: NON_NULL

server:
  port: 8080

logging:
  level:
    com.codex: DEBUG

springdoc:
  swagger-ui:
    path: /swagger-ui.html
    enabled: true
```

## 📚 Key Dependencies

- **Spring Boot 4.0.3**: Web framework
- **Springdoc OpenAPI 2.2.0**: Swagger/OpenAPI documentation
- **Lombok**: Boilerplate reduction
- **Spring Cloud Azure**: Azure integration
- **GSON**: JSON processing

## 🔐 Security Considerations

- Input validation on all endpoints
- Consistent error messages (no sensitive data leakage)
- Environment-based configuration for secrets
- Proper HTTP status codes
- Global exception handling

## 📈 Extensibility

Easily extend the application by creating new services and controllers following the established patterns.

## 🆘 Troubleshooting

### Port Already in Use

Configure different port in `application.yml`:

```yaml
server:
  port: 8081

```

### Dependency Issues

```bash
.\mvnw.cmd clean install -U
```

---

**Last Updated**: March 11, 2026
**Version**: 0.0.1-SNAPSHOT
**Java Version**: 25
**Spring Boot**: 4.0.3
