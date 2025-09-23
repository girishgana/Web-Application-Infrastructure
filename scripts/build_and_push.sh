#!/bin/bash
set -e

# Usage: build_and_push.sh <aws_profile> <region> <ecr_repo> <image_tag>

AWS_PROFILE=${1:-default}
REGION=${2:-ap-south-1}
ECR_REPO=${3:-prod-web-repo}
IMAGE_TAG=${4:-latest}

ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --region "$REGION" --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}"

# Build
docker build -t "${ECR_URI}:${IMAGE_TAG}" -f docker/Dockerfile .

# Authenticate and push
aws ecr get-login-password --profile "$AWS_PROFILE" --region "$REGION" | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
docker push "${ECR_URI}:${IMAGE_TAG}"

echo "Pushed ${ECR_URI}:${IMAGE_TAG}"
