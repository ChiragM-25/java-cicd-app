pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "chiragm25/java-cicd-app"
    }

    stages {

        stage('Build JAR') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                '''
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
                    echo $PASSWORD | docker login -u $USERNAME --password-stdin
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker push $IMAGE_NAME:$BUILD_NUMBER

                docker tag $IMAGE_NAME:$BUILD_NUMBER $IMAGE_NAME:latest
                docker push $IMAGE_NAME:latest
                '''
            }
        }

        stage('Deploy via SSM (Docker)') {
            steps {
                script {
                    sh """
                    INSTANCE_IDS=\$(aws ec2 describe-instances \
                    --filters "Name=tag:App,Values=java-app" \
                    --query "Reservations[*].Instances[*].InstanceId" \
                    --output text \
                    --region ap-south-1)

                    echo "Deploying to: \$INSTANCE_IDS"

                    aws ssm send-command \
                    --region ap-south-1 \
                    --instance-ids \$INSTANCE_IDS \
                    --document-name "AWS-RunShellScript" \
                    --parameters commands="[
                        \\"docker pull chiragm25/java-cicd-app:latest\\",
                        \\"docker rm -f \$(docker ps -aq) || true\\",
                        \\"docker run -d -p 8080:8080 -e BUILD_VERSION=${BUILD_NUMBER} chiragm25/java-cicd-app:latest\\"
                    ]"
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