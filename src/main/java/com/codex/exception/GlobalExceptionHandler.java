package com.codex.exception;

import com.codex.dto.ApiResponse;
import com.codex.dto.ErrorDetailDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.util.ArrayList;
import java.util.List;

/**
 * Global exception handler for application-wide error handling.
 * Provides consistent error responses across all API endpoints.
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Handle validation exceptions for invalid request body.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<List<ErrorDetailDto>>> handleValidationExceptions(
            MethodArgumentNotValidException ex, WebRequest request) {

        List<ErrorDetailDto> errorDetails = new ArrayList<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            Object rejectedValue = ((FieldError) error).getRejectedValue();

            ErrorDetailDto errorDetail = ErrorDetailDto.builder()
                    .field(fieldName)
                    .message(errorMessage)
                    .rejectedValue(rejectedValue)
                    .build();

            errorDetails.add(errorDetail);
        });

        log.warn("Validation error occurred: {}", errorDetails);

        ApiResponse<List<ErrorDetailDto>> response = ApiResponse.validationError(
                "Validation failed for the request",
                "VALIDATION_FAILED",
                errorDetails);

        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    /**
     * Handle resource not found exceptions.
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleResourceNotFoundException(
            ResourceNotFoundException ex, WebRequest request) {

        log.error("Resource not found: {}", ex.getMessage());

        ApiResponse<Void> response = ApiResponse.error(
                ex.getMessage(),
                ex.getErrorCode());

        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    /**
     * Handle validation exceptions.
     */
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidationException(
            ValidationException ex, WebRequest request) {

        log.error("Validation error: {}", ex.getMessage());

        ApiResponse<Void> response = ApiResponse.error(
                ex.getMessage(),
                ex.getErrorCode());

        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    /**
     * Handle application exceptions.
     */
    @ExceptionHandler(ApplicationException.class)
    public ResponseEntity<ApiResponse<Void>> handleApplicationException(
            ApplicationException ex, WebRequest request) {

        log.error("Application error: {} - {}", ex.getErrorCode(), ex.getMessage());

        ApiResponse<Void> response = ApiResponse.error(
                ex.getMessage(),
                ex.getErrorCode());

        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    /**
     * Handle all other exceptions.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGlobalException(
            Exception ex, WebRequest request) {

        log.error("An unexpected error occurred", ex);

        ApiResponse<Void> response = ApiResponse.error(
                "An unexpected error occurred while processing the request",
                "INTERNAL_SERVER_ERROR");

        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
