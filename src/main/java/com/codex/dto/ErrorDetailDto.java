package com.codex.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

/**
 * DTO for error details in validation scenarios.
 * Provides detailed information about validation failures.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorDetailDto implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private String field;
    private String message;
    private Object rejectedValue;
}
