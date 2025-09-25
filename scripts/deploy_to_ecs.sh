#!/bin/bash
set -e
# Usage: deploy_to_ecs.sh <aws_profile> <region> <cluster> <service> <task_family> <container_name> <image_uri>

AWS_PROFILE=${1:-default}
REGION=${2:-ap-south-1}
CLUSTER=${3:-prod-ecs-cluster3}
SERVICE=${4:-prod-web-service}
TASK_FAMILY=${5:-prod-web-task}
CONTAINER_NAME=${6:-prod-web-container}
IMAGE_URI=${7:?image uri required}

# Register new task definition revision by pulling current task def and patching container image
CURRENT_TASK_ARN=$(aws ecs describe-services --profile "$AWS_PROFILE" --region "$REGION" --cluster "$CLUSTER" --services "$SERVICE" --query "services[0].taskDefinition" --output text)
TASK_JSON=$(aws ecs describe-task-definition --profile "$AWS_PROFILE" --region "$REGION" --task-definition "$CURRENT_TASK_ARN" --query "taskDefinition" --output json)

# Remove fields not allowed in register-task-definition
NEW_TASK_DEF=$(echo "$TASK_JSON" | jq "del(.status, .revision, .taskDefinitionArn, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy) | .containerDefinitions |= map(if .name==\"${CONTAINER_NAME}\" then .image=\"${IMAGE_URI}\" else . end)")

echo "$NEW_TASK_DEF" > /tmp/new-task-def.json

aws ecs register-task-definition --profile "$AWS_PROFILE" --region "$REGION" --cli-input-json file:///tmp/new-task-def.json

# Update service to use latest task definition
NEW_TASK_FAMILY_REVISION=$(aws ecs list-task-definitions --profile "$AWS_PROFILE" --region "$REGION" --family-prefix "$TASK_FAMILY" --sort DESC --max-items 1 --query "taskDefinitionArns[0]" --output text)
aws ecs update-service --profile "$AWS_PROFILE" --region "$REGION" --cluster "$CLUSTER" --service "$SERVICE" --task-definition "$NEW_TASK_FAMILY_REVISION"

echo "Service updated. New task: $NEW_TASK_FAMILY_REVISION"
