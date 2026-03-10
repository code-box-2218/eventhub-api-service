package com.codex.controller;

import com.codex.constant.ApiConstants;
import com.codex.dto.ApiResponse;
import com.codex.dto.AppInfoDto;
import com.codex.service.AppInfoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST Controller for Application Information endpoints.
 * Provides endpoints to retrieve application metadata and configuration
 * details.
 */
@RestController
@RequestMapping(ApiConstants.API_PREFIX + ApiConstants.APPINFO_ENDPOINT)
public class AppInfoController {

    private static final Logger logger = LoggerFactory.getLogger(AppInfoController.class);

    @Autowired
    private AppInfoService appInfoService;

    /**
     * Retrieves application information and metadata.
     *
     * @return ResponseEntity with ApiResponse containing AppInfoDto
     */
    @GetMapping
    public ResponseEntity<ApiResponse<AppInfoDto>> getAppInfo() {
        logger.info(ApiConstants.APPINFO_GET_LOG);

        try {
            AppInfoDto appInfo = appInfoService.getAppInfo();
            ApiResponse<AppInfoDto> response = ApiResponse.success(ApiConstants.APPINFO_SUCCESS_MESSAGE,
                    appInfo);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error(ApiConstants.APPINFO_ERROR_LOG, e);
            ApiResponse<AppInfoDto> errorResponse = ApiResponse.error(ApiConstants.APPINFO_ERROR_MESSAGE,
                    ApiConstants.APPINFO_RETRIEVAL_ERROR);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
