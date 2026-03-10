package com.codex.exception;

import java.io.Serial;

/**
 * Exception thrown when a requested resource is not found.
 * Maps to HTTP 404 Not Found response.
 */
public class ResourceNotFoundException extends ApplicationException {

    @Serial
    private static final long serialVersionUID = 1L;

    public ResourceNotFoundException(String message) {
        super(message, "RESOURCE_NOT_FOUND");
    }

    public ResourceNotFoundException(String message, String details) {
        super(message, "RESOURCE_NOT_FOUND", details);
    }
}
