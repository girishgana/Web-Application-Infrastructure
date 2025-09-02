output "vpc_id"                 { value = module.vpc.vpc_id }
output "private_subnet_ids"     { value = module.vpc.private_subnet_ids }
output "public_subnet_ids"      { value = module.vpc.public_subnet_ids }
output "cluster_name"           { value = module.eks.cluster_name }
output "ecr_repo_url"           { value = aws_ecr_repository.app.repository_url }
output "rds_endpoint"           { value = module.rds.rds_endpoint }
output "db_secret_arn"          { value = module.rds.db_secret_arn }
