package com.codex.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Generic API response wrapper for consistent API responses.
 * Provides standardized response structure for all API endpoints.
 * 
 * @param <T> Generic type for response data
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    private String status;
    private String message;
    private T data;
    private LocalDateTime timestamp;
    private String errorCode;

    /**
     * Build a success response with data.
     */
    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
                .status("SUCCESS")
                .message(message)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * Build an error response without data.
     */
    public static <T> ApiResponse<T> error(String message, String errorCode) {
        return ApiResponse.<T>builder()
                .status("ERROR")
                .message(message)
                .errorCode(errorCode)
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * Build a validation error response.
     */
    public static <T> ApiResponse<T> validationError(String message, String errorCode, T data) {
        return ApiResponse.<T>builder()
                .status("VALIDATION_ERROR")
                .message(message)
                .errorCode(errorCode)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }
}
