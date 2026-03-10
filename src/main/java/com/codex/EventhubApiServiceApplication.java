package com.codex;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

/**
 * Main Spring Boot Application entry point.
 * Initializes and runs the EventHub API Service application.
 */
@Slf4j
@SpringBootApplication
public class EventhubApiServiceApplication {

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(EventhubApiServiceApplication.class);
		ConfigurableApplicationContext context = app.run(args);

		Environment env = context.getEnvironment();
		String port = env.getProperty("server.port", "8080");
		String contextPath = env.getProperty("server.servlet.context-path", "/");

		log.info("================================");
		log.info("EventHub API Service is running");
		log.info("Access Swagger UI at: http://localhost:{}{}swagger-ui.html", port, contextPath);
		log.info("================================");
	}
}