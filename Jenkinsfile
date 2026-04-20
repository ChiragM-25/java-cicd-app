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

        // ✅ NEW STAGE (added cleanly)
        stage('Upload deploy.sh to S3') {
            steps {
                sh """
                aws s3 cp deploy.sh s3://java-cicd-app-deploy-scripts/deploy.sh --region $AWS_REGION
                """
            }
        }

        // ✅ FIXED DEPLOY STAGE (only this part replaced)
        stage('Deploy via SSM') {
            steps {
                sh """
                aws ssm send-command \
                  --document-name "AWS-RunShellScript" \
                  --targets "Key=tag:App,Values=java-app" \
                  --parameters 'commands=[
                    "aws s3 cp s3://java-cicd-app-deploy-scripts/deploy.sh /home/ec2-user/deploy.sh",
                    "chmod +x /home/ec2-user/deploy.sh",
                    "/home/ec2-user/deploy.sh $IMAGE_NAME $BUILD_NUMBER"
                  ]' \
                  --region $AWS_REGION
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