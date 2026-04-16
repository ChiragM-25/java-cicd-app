pipeline {
    agent any

    environment {
        IMAGE_NAME = "chiragm25/java-cicd-app"
        AWS_REGION = "ap-south-1"
    }

    stages {

        stage('Build JAR') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                """
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'Docker_hub_access',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    sh '''
                    printf "%s" "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                sh """
                docker push $IMAGE_NAME:$BUILD_NUMBER
                docker tag $IMAGE_NAME:$BUILD_NUMBER $IMAGE_NAME:latest
                docker push $IMAGE_NAME:latest
                """
            }
        }

        stage('Deploy via SSM (Docker)') {
            steps {
                script {

                    // 🔍 Get EC2 instances dynamically using tag
                    def INSTANCE_IDS = sh(
                        script: """
                        aws ec2 describe-instances \
                        --filters "Name=tag:App,Values=java-app" \
                        --query "Reservations[*].Instances[*].InstanceId" \
                        --output text \
                        --region $AWS_REGION
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Deploying to: ${INSTANCE_IDS}"

                    // 🚀 Deploy using SSM
                    sh """
                    aws ssm send-command \
                    --region $AWS_REGION \
                    --instance-ids ${INSTANCE_IDS} \
                    --document-name AWS-RunShellScript \
                    --parameters commands='[
                        "docker pull $IMAGE_NAME:latest",
                        "docker rm -f java-app-container || true",
                        "docker run -d -p 8080:8080 --name java-app-container -e BUILD_VERSION=${BUILD_NUMBER} $IMAGE_NAME:latest"
                    ]'
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build ${BUILD_NUMBER} deployed successfully"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}