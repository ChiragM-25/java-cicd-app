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
        return "Jenkins CI/CD Pipeline with AWS Infrastructure & Docker!";
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoJavaPprojectApplication.class, args);
    }
}
