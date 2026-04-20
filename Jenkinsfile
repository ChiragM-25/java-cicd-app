pipeline {
    agent any

    environment {
        IMAGE_NAME = "chiragm25/java-cicd-app"
        AWS_REGION = "ap-south-1"
        S3_BUCKET = "java-cicd-app-deploy-scripts"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    """
                }
            }
        }

        stage('Push Image') {
            steps {
                sh """
                docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                docker push ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Upload Deploy Script to S3') {
            steps {
                sh """
                aws s3 cp deploy.sh s3://${S3_BUCKET}/deploy.sh
                """
            }
        }

        stage('Deploy via SSM') {
            steps {
                sh """
                aws ssm send-command \
                  --document-name "AWS-RunShellScript" \
                  --targets "Key=tag:App,Values=java-app" \
                  --parameters commands=[
                    \\"aws s3 cp s3://${S3_BUCKET}/deploy.sh /home/ec2-user/deploy.sh\\",
                    \\"chmod +x /home/ec2-user/deploy.sh\\",
                    \\"/home/ec2-user/deploy.sh ${IMAGE_NAME} ${BUILD_NUMBER}\\"
                  ] \
                  --region ${AWS_REGION}
                """
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}