package com.codex.service;

import com.codex.dto.AppInfoDto;

/**
 * Service interface for Application Information operations.
 * Handles retrieval of application metadata and configuration details.
 */
public interface AppInfoService {

    /**
     * Retrieves application information including version, environment, and uptime.
     *
     * @return AppInfoDto containing application details
     */
    AppInfoDto getAppInfo();
}
