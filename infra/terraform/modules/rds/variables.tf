variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "eks_cluster_sg_id" { type = string }
variable "db_name" { type = string, default = "appdb" }
variable "db_username" { type = string, default = "appuser" }
variable "instance_class" { type = string, default = "db.t3.medium" }
variable "tags" { type = map(string), default = {} }
