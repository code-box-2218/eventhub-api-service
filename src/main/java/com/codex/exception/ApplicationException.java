package com.codex.exception;

import lombok.Getter;

import java.io.Serial;

/**
 * Base exception class for application-specific exceptions.
 * Provides standard exception handling across the application.
 */
@Getter
public class ApplicationException extends RuntimeException {

    @Serial
    private static final long serialVersionUID = 1L;

    private final String errorCode;
    private final String details;

    public ApplicationException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
        this.details = null;
    }

    public ApplicationException(String message, String errorCode, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
        this.details = null;
    }

    public ApplicationException(String message, String errorCode, String details) {
        super(message);
        this.errorCode = errorCode;
        this.details = details;
    }

}
