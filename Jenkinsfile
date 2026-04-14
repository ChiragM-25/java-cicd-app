pipeline {
    agent any

    environment {
        S3_BUCKET = "my-java-cicd-bucket"
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

        stage('Deploy via SSM') {
            steps {
                sh '''
                aws ssm send-command \
                  --targets "Key=tag:App,Values=java-app" \
                  --document-name "AWS-RunShellScript" \
                  --parameters 'commands=[
                    "aws s3 cp s3://'$S3_BUCKET'/app-'$BUILD_NUMBER'.jar /home/ec2-user/app.jar",
                    "pkill -f app.jar || true",
                    "nohup java -jar /home/ec2-user/app.jar > app.log 2>&1 &"
                  ]'
                '''
            }
        }
    }
}