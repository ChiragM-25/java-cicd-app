pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/ChiragM-25/java-cicd-app.git'
            }
        }

        stage('Build') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}