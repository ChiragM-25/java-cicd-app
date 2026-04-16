pipeline {
    agent any

    environment {
        IMAGE_NAME = "chiragm25/java-cicd-app"
        AWS_REGION = "ap-south-1"
        CONTAINER_NAME = "java-app-container"
    }

    stages {

        stage('Build JAR') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                sh """
                docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                docker tag $IMAGE_NAME:$BUILD_NUMBER $IMAGE_NAME:latest
                """
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'Docker_hub_access',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    sh """
                    printf "%s" "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                    docker push $IMAGE_NAME:$BUILD_NUMBER
                    docker push $IMAGE_NAME:latest
                    """
                }
            }
        }

        stage('Deploy to EC2 via SSM') {
            steps {
                script {

                    def instanceIds = sh(
                        script: """
                        aws ec2 describe-instances \
                        --filters "Name=tag:App,Values=java-app" \
                        --query "Reservations[*].Instances[*].InstanceId" \
                        --output text \
                        --region $AWS_REGION
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Deploying to: ${instanceIds}"

                    def deployCmd = """
                    docker pull $IMAGE_NAME:latest &&
                    docker rm -f $CONTAINER_NAME || true &&
                    docker run -d -p 8080:8080 \
                        --name $CONTAINER_NAME \
                        -e BUILD_VERSION=$BUILD_NUMBER \
                        $IMAGE_NAME:latest
                    """

                    sh """
                    aws ssm send-command \
                    --region $AWS_REGION \
                    --instance-ids ${instanceIds} \
                    --document-name AWS-RunShellScript \
                    --parameters commands='["${deployCmd}"]'
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