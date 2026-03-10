package com.codex.constant;

/**
 * Central location for API constants and configuration values.
 * Reduces magic strings and centralizes configuration.
 */
public final class ApiConstants {

    private ApiConstants() {
        // Private constructor to prevent instantiation
    }

    // API Paths
    public static final String API_BASE_PATH = "/api";
    public static final String API_VERSION = "/v1";
    public static final String API_PREFIX = API_BASE_PATH + API_VERSION;

    // Endpoints
    public static final String HEALTH_ENDPOINT = "/health";
    public static final String STATUS_ENDPOINT = "/status";
    public static final String APPINFO_ENDPOINT = "/appinfo";

    // Common Response Messages
    public static final String SUCCESS_MESSAGE = "Operation completed successfully";
    public static final String ERROR_MESSAGE = "An error occurred while processing the request";
    public static final String VALIDATION_ERROR = "Validation failed";
    public static final String NOT_FOUND_MESSAGE = "Resource not found";
    public static final String APPINFO_SUCCESS_MESSAGE = "Application information retrieved successfully";
    public static final String APPINFO_ERROR_MESSAGE = "Failed to retrieve application information";

    // HTTP Status Messages
    public static final String OK_STATUS = "OK";

    // Error Codes
    public static final String APPINFO_RETRIEVAL_ERROR = "APP_INFO_RETRIEVAL_ERROR";

    // Logging Messages
    public static final String APPINFO_GET_LOG = "GET " + API_PREFIX + APPINFO_ENDPOINT
            + " - Retrieving application information";
    public static final String APPINFO_ERROR_LOG = "Error retrieving application information";
    public static final String ERROR_STATUS = "ERROR";
    public static final String VALIDATION_STATUS = "VALIDATION_ERROR";

    // Default Values
    public static final String DEFAULT_TIMEZONE = "UTC";
    public static final int DEFAULT_TIMEOUT_MS = 5000;
}
