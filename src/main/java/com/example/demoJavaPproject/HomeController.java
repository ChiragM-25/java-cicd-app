package com.example.demoJavaPproject;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    @Value("${BUILD_VERSION:local}")
    private String buildVersion;

    @GetMapping("/")
    public String home() {
        return """
            <html>
            <head>
                <title>CI/CD App</title>
                <style>
                    body {
                        font-family: Arial;
                        text-align: center;
                        margin-top: 100px;
                        background-color: #f4f4f4;
                    }
                    .card {
                        background: white;
                        padding: 30px;
                        border-radius: 10px;
                        box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
                        display: inline-block;
                    }
                    h1 {
                        color: #2c3e50;
                    }
                    .status {
                        color: green;
                        font-weight: bold;
                    }
                    .build {
                        color: #555;
                        margin-top: 10px;
                    }
                </style>
            </head>
            <body>
                <div class="card">
                    <h1>🚀 CI/CD Pipeline</h1>
                    <p class="status">Application Running Successfully</p>
                    <p>Deployed via Jenkins + Docker + AWS</p>
                    <p class="build">Build Version: %s</p>
                </div>
            </body>
            </html>
        """.formatted(buildVersion);
    }
}