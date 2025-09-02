terraform {
  required_version = ">= 1.5.0"
  backend "s3" {} # configure in tfvars or CLI
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.50" }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source               = "./modules/vpc"
  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "eks" {
  source             = "./modules/eks"
  name               = "${var.name}-eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  desired_size       = var.eks_desired_size
  min_size           = var.eks_min_size
  max_size           = var.eks_max_size
  instance_types     = var.eks_instance_types
  tags               = var.tags
}

module "rds" {
  source             = "./modules/rds"
  name               = "${var.name}"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_cluster_sg_id  = module.eks.cluster_security_group_id
  db_name            = var.db_name
  db_username        = var.db_username
  instance_class     = var.rds_instance_class
  tags               = var.tags
}

# ECR for images
resource "aws_ecr_repository" "app" {
  name = "${var.name}-app"
  image_scanning_configuration { scan_on_push = true }
  tags = var.tags
}

# SNS Topic for alarms
resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
  tags = var.tags
}

# Example CloudWatch alarm - EKS node CPU
data "aws_autoscaling_group" "eks_ng" {
  name = module.eks.this_node_group_id != null ? module.eks.this_node_group_id : ""
  depends_on = [module.eks]
}

# (Optional) Cluster control plane log group retention
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${module.eks.cluster_name}/cluster"
  retention_in_days = 30
  tags              = var.tags
}

output "cluster_name"   { value = module.eks.cluster_name }
output "ecr_repo_url"   { value = aws_ecr_repository.app.repository_url }
output "rds_endpoint"   { value = module.rds.rds_endpoint }
output "db_secret_arn"  { value = module.rds.db_secret_arn }
