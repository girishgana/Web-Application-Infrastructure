# Web-Application-Infrastructure

# prod-web-app

Simple Flask web app deployed to AWS ECS Fargate behind ALB with RDS Postgres.

## Repo structure
(see earlier)

## Prerequisites
- AWS account + permissions
- AWS CLI configured locally
- Docker installed
- GitHub repo with AWS credentials stored as secrets (or configure OIDC)

## Environment variables (copy from .env.example)
- AWS_REGION, ECR_REPO, etc.

## Build & push locally
./scripts/build_and_push.sh <aws_profile> <region> <ecr_repo> <tag>

## Deploy to ECS locally
./scripts/deploy_to_ecs.sh <aws_profile> <region> <cluster> <service> <task_family> <container_name> <image_uri>

## CI/CD
Configured GitHub Actions workflow in `.github/workflows/ci-cd.yml`
- On push to main, builds image, scans, pushes to ECR, updates ECS task definition and service.

## Manual AWS Console steps
1. Create VPC and subnets (public/private across 2 AZs)
2. Create IGW + NAT
3. Create Security Groups (sg-alb, sg-app, sg-rds, sg-bastion)
4. Launch bastion EC2 in public subnet
5. Create RDS (Postgres) in private subnets
6. Create ECR repo
7. Create ECS cluster, task definition (Fargate), service
8. Create ALB in public subnets and target group for ECS (port 8080)
9. Store DB password in Secrets Manager and map in task definition
10. Configure CloudWatch logs and monitoring

## Verification
1. Access ALB DNS in browser
2. Check ECS tasks & service
3. Check CloudWatch logs

## Security notes
- Use Secrets Manager or SSM Parameter Store for secrets
- Use role-based access for CI (OIDC)
- Use HTTPS on ALB (ACM cert)
