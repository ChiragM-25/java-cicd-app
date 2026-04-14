package com.example.demoJavaPproject;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class DemoJavaPprojectApplication {

    @GetMapping("/")
    public String home() {
        return "Hello from Jenkins CI/CD Pipeline!";
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoJavaPprojectApplication.class, args);
    }
}
