pipeline {
    agent any

    environment {
        S3_BUCKET = "chrg-dvop-artifacts"
    }

    stages {

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

        stage('Upload to S3') {
            steps {
                sh '''
                aws s3 cp target/demoJavaPproject-0.0.1-SNAPSHOT.jar \
                s3://$S3_BUCKET/app-${BUILD_NUMBER}.jar
                '''
            }
        }
    }
}