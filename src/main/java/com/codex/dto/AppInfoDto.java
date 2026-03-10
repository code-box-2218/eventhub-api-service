package com.codex.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

/**
 * Data Transfer Object for Application Information.
 * Contains metadata and details about the application.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AppInfoDto implements Serializable {

    private static final long serialVersionUID = 1L;

    private String appName;
    private String appVersion;
    private String appDescription;
    private String environment;
    private String javaVersion;
    private Long uptime;
}
