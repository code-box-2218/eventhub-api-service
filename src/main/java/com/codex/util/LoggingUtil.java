package com.codex.util;

import lombok.extern.slf4j.Slf4j;

/**
 * Utility class for consistent logging across the application.
 * Provides helper methods for logging with consistent formatting.
 */
@Slf4j
public final class LoggingUtil {

    private LoggingUtil() {
        // Private constructor to prevent instantiation
    }

    /**
     * Log method entry with parameters.
     */
    public static void logMethodEntry(String methodName, Object... params) {
        if (log.isDebugEnabled()) {
            StringBuilder sb = new StringBuilder();
            sb.append("Method entry: ").append(methodName);
            if (params.length > 0) {
                sb.append(" with parameters: ");
                for (Object param : params) {
                    sb.append(param).append(", ");
                }
            }
            log.debug(sb.toString());
        }
    }

    /**
     * Log method exit.
     */
    public static void logMethodExit(String methodName) {
        if (log.isDebugEnabled()) {
            log.debug("Method exit: {}", methodName);
        }
    }

    /**
     * Log method exit with result.
     */
    public static void logMethodExit(String methodName, Object result) {
        if (log.isDebugEnabled()) {
            log.debug("Method exit: {} with result: {}", methodName, result);
        }
    }

    /**
     * Log error with context.
     */
    public static void logError(String message, Exception ex) {
        log.error("Error: {} - Exception: {}", message, ex.getMessage(), ex);
    }

    /**
     * Log warning message.
     */
    public static void logWarning(String message, Object... params) {
        log.warn(message, params);
    }
}
