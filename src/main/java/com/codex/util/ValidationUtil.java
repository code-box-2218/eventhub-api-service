package com.codex.util;

import com.codex.exception.ValidationException;
import lombok.extern.slf4j.Slf4j;

import java.util.Collection;

/**
 * Utility class for validation operations.
 * Provides reusable validation methods across the application.
 */
@Slf4j
public final class ValidationUtil {

    private ValidationUtil() {
        // Private constructor to prevent instantiation
    }

    /**
     * Validate that a string is not null or empty.
     */
    public static void validateNotEmpty(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            log.error("Validation failed: {} cannot be empty", fieldName);
            throw new ValidationException(fieldName + " cannot be empty or null");
        }
    }

    /**
     * Validate that an object is not null.
     */
    public static void validateNotNull(Object value, String fieldName) {
        if (value == null) {
            log.error("Validation failed: {} cannot be null", fieldName);
            throw new ValidationException(fieldName + " cannot be null");
        }
    }

    /**
     * Validate that a collection is not empty.
     */
    public static void validateNotEmpty(Collection<?> collection, String fieldName) {
        if (collection == null || collection.isEmpty()) {
            log.error("Validation failed: {} cannot be empty", fieldName);
            throw new ValidationException(fieldName + " cannot be empty");
        }
    }

    /**
     * Validate that a value is greater than a minimum.
     */
    public static void validateMinimum(int value, int minimum, String fieldName) {
        if (value < minimum) {
            log.error("Validation failed: {} must be at least {}", fieldName, minimum);
            throw new ValidationException(fieldName + " must be at least " + minimum);
        }
    }

    /**
     * Validate that a string matches a pattern.
     */
    public static void validatePattern(String value, String pattern, String fieldName) {
        if (value != null && !value.matches(pattern)) {
            log.error("Validation failed: {} does not match pattern", fieldName);
            throw new ValidationException(fieldName + " does not match the required pattern");
        }
    }
}
