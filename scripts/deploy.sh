#!/bin/bash
set -euxo pipefail

IMAGE_NAME=$1
BUILD_NUMBER=$2

echo "=== Pulling image ==="
docker pull $IMAGE_NAME:$BUILD_NUMBER

echo "=== Stopping old container ==="
docker rm -f java-app-container || true

echo "=== Starting new container ==="
docker run -d \
  --name java-app-container \
  -p 8080:8080 \
  -e BUILD_VERSION=$BUILD_NUMBER \
  --restart unless-stopped \
  $IMAGE_NAME:$BUILD_NUMBER

echo "=== Waiting for app ==="
sleep 10

echo "=== Health check ==="
curl -f http://localhost:8080/actuator/health

echo "=== Cleaning up old images ==="
docker image prune -af || true

echo "=== Deployment complete ==="