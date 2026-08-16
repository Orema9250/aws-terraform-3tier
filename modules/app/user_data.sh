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

# Start backend container
docker run -d \
  --name backend \
  --restart unless-stopped \
  -p 8000:8000 \
  ${ecr_image}:${ecr_image_tag}