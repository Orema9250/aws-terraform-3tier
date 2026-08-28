#!/bin/bash

set -e

# Update packages and install Docker + AWS CLI
apt-get update -y
apt-get install -y docker.io awscli

# Start Docker
systemctl enable docker
systemctl start docker

# ECR registry
ECR_REGISTRY=$(echo "${ecr_image}" | cut -d/ -f1)

# Authenticate Docker with ECR
aws ecr get-login-password --region ${region} | \
docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Pull application image
docker pull ${ecr_image}:${ecr_image_tag}

# Create secure directory for the database secret
mkdir -p /run/backend
chmod 700 /run/backend

# Retrieve database credentials from AWS Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id "${db_secret_arn}" \
  --query SecretString \
  --output text > /run/backend/db-secret.json

# Restrict access to the secret
chmod 600 /run/backend/db-secret.json

# Start backend container
docker run -d \
  --name backend \
  --restart unless-stopped \
  -p 8000:8000 \
  -v /run/backend/db-secret.json:/run/secrets/backend-db-secret.json:ro \
  ${ecr_image}:${ecr_image_tag}