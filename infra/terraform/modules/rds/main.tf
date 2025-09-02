terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.50" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "RDS access from EKS nodes"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_from_nodes" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.eks_cluster_sg_id
}

resource "random_password" "db" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.name}/db"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "postgres"
    host     = "" # filled after instance creation via README step (optional)
    port     = 5432
    dbname   = var.db_name
  })
}

resource "aws_db_parameter_group" "pg" {
  name   = "${var.name}-pg"
  family = "postgres16"
}

resource "aws_db_instance" "this" {
  identifier              = "${var.name}-postgres"
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = var.instance_class
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  username                = var.db_username
  password                = random_password.db.result
  db_name                 = var.db_name
  multi_az                = true
  backup_retention_period = 7
  delete_automated_backups= true
  deletion_protection     = false
  publicly_accessible     = false
  parameter_group_name    = aws_db_parameter_group.pg.name
  storage_encrypted       = true
  skip_final_snapshot     = true
  monitoring_interval     = 60
  performance_insights_enabled = true
  tags                    = var.tags
}

output "rds_endpoint" { value = aws_db_instance.this.address }
output "rds_sg_id"    { value = aws_security_group.rds.id }
output "db_secret_arn" { value = aws_secretsmanager_secret.db.arn }
