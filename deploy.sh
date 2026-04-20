#!/bin/bash

set -e

IMAGE_NAME="$1"
BUILD_NUMBER="$2"

echo "=== Detecting active port ==="

ACTIVE_PORT=$(grep -o '808[12]' /etc/nginx/nginx.conf)

if [ "$ACTIVE_PORT" == "8081" ]; then
  NEW_PORT=8082
  OLD_PORT=8081
  NEW_ENV="green"
  OLD_ENV="blue"
else
  NEW_PORT=8081
  OLD_PORT=8082
  NEW_ENV="blue"
  OLD_ENV="green"
fi

echo "Active: $OLD_ENV ($OLD_PORT)"
echo "Deploying to: $NEW_ENV ($NEW_PORT)"

echo "=== Pulling latest image ==="
docker pull $IMAGE_NAME:latest

echo "=== Removing existing $NEW_ENV container if exists ==="
docker rm -f java-app-$NEW_ENV || true

echo "=== Starting new container ==="
docker run -d \
  --name java-app-$NEW_ENV \
  -p $NEW_PORT:8080 \
  -e BUILD_VERSION=$BUILD_NUMBER \
  --restart unless-stopped \
  $IMAGE_NAME:latest

echo "=== Waiting for app to boot ==="
sleep 10

echo "=== Running health check ==="
if ! curl -f http://localhost:$NEW_PORT/actuator/health; then
  echo "Health check FAILED. Aborting."
  docker rm -f java-app-$NEW_ENV
  exit 1
fi

echo "=== Switching traffic in NGINX ==="
sudo sed -i "s/$OLD_PORT/$NEW_PORT/" /etc/nginx/nginx.conf
sudo systemctl reload nginx

echo "=== Cleaning up old container ==="
docker rm -f java-app-$OLD_ENV || true

echo "=== Deployment complete ==="