package com.example.demo.controller;

import java.net.InetAddress;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
public class ServerInfoController {

    @GetMapping("/")
    public String home() {
        return "Привет от Java Spring Boot приложения в Docker!";
    }

    @GetMapping("/api/info")
    public Map<String, Object> getServerInfo() {
        log.info("Запрос информации о сервере");
        Map<String, Object> info = new HashMap<>();
        try {
            info.put("hostname", InetAddress.getLocalHost().getHostName());
            info.put("ip", InetAddress.getLocalHost().getHostAddress());
            info.put("javaVersion", System.getProperty("java.version"));
            info.put("osName", System.getProperty("os.name"));
            info.put("osVersion", System.getProperty("os.version"));
            info.put("timestamp", LocalDateTime.now().toString());
            info.put("availableProcessors", Runtime.getRuntime().availableProcessors());
            info.put("freeMemory", Runtime.getRuntime().freeMemory());
            info.put("maxMemory", Runtime.getRuntime().maxMemory());
        } catch (Exception e) {
            log.error("Ошибка при получении информации о сервере", e);
            info.put("error", e.getMessage());
        }
        return info;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        status.put("time", LocalDateTime.now().toString());
        return status;
    }
} 