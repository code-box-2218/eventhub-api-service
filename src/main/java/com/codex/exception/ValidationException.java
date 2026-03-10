package com.codex.exception;

import java.io.Serial;

/**
 * Exception thrown when input validation fails.
 * Maps to HTTP 400 Bad Request response.
 */
public class ValidationException extends ApplicationException {

    @Serial
    private static final long serialVersionUID = 1L;

    public ValidationException(String message) {
        super(message, "VALIDATION_FAILED");
    }

    public ValidationException(String message, String details) {
        super(message, "VALIDATION_FAILED", details);
    }
}
