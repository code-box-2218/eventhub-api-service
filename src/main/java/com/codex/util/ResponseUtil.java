package com.codex.util;

import com.codex.constant.ApiConstants;
import com.codex.dto.ApiResponse;

/**
 * Utility class for building API responses.
 * Centralizes response creation logic for consistency.
 */
public final class ResponseUtil {

    private ResponseUtil() {
        // Private constructor to prevent instantiation
    }

    /**
     * Build a success response.
     */
    public static <T> ApiResponse<T> buildSuccessResponse(String message, T data) {
        return ApiResponse.success(message, data);
    }

    /**
     * Build a success response with default message.
     */
    public static <T> ApiResponse<T> buildSuccessResponse(T data) {
        return ApiResponse.success(ApiConstants.SUCCESS_MESSAGE, data);
    }

    /**
     * Build an error response.
     */
    public static <T> ApiResponse<T> buildErrorResponse(String message, String errorCode) {
        return ApiResponse.error(message, errorCode);
    }

    /**
     * Build an error response with default code.
     */
    public static <T> ApiResponse<T> buildErrorResponse(String message) {
        return ApiResponse.error(message, "UNKNOWN_ERROR");
    }

    /**
     * Build a validation error response.
     */
    public static <T> ApiResponse<T> buildValidationErrorResponse(String message, T data) {
        return ApiResponse.validationError(message, "VALIDATION_FAILED", data);
    }
}
