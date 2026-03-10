package com.codex.service.impl;

import com.codex.dto.AppInfoDto;
import com.codex.service.AppInfoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.lang.management.ManagementFactory;

/**
 * Implementation of AppInfoService.
 * Provides application information and metadata.
 */
@Service
public class AppInfoServiceImpl implements AppInfoService {

    private static final Logger logger = LoggerFactory.getLogger(AppInfoServiceImpl.class);

    @Value("${spring.application.name:EventHub API Service}")
    private String appName;

    @Value("${app.version:1.0.0}")
    private String appVersion;

    @Value("${app.description:Event Hub API Service}")
    private String appDescription;

    @Value("${spring.profiles.active:unknown}")
    private String environment;

    @Override
    public AppInfoDto getAppInfo() {
        logger.info("Fetching application information");

        String javaVersion = System.getProperty("java.version");
        Long uptime = ManagementFactory.getRuntimeMXBean().getUptime();

        return AppInfoDto.builder()
                .appName(appName)
                .appVersion(appVersion)
                .appDescription(appDescription)
                .environment(environment)
                .javaVersion(javaVersion)
                .uptime(uptime)
                .build();
    }
}
