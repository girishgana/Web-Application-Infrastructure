variable "name" { type = string }
variable "region" { type = string, default = "ap-south-1" }

variable "vpc_cidr" { type = string, default = "10.0.0.0/16" }
variable "azs" { type = list(string), default = ["ap-south-1a","ap-south-1b"] }
variable "public_subnet_cidrs" { type = list(string), default = ["10.0.0.0/24","10.0.1.0/24"] }
variable "private_subnet_cidrs" { type = list(string), default = ["10.0.10.0/24","10.0.11.0/24"] }

variable "eks_min_size" { type = number, default = 2 }
variable "eks_desired_size" { type = number, default = 2 }
variable "eks_max_size" { type = number, default = 4 }
variable "eks_instance_types" { type = list(string), default = ["t3.medium"] }

variable "db_name" { type = string, default = "appdb" }
variable "db_username" { type = string, default = "appuser" }
variable "rds_instance_class" { type = string, default = "db.t3.medium" }

variable "tags" { type = map(string), default = { Project = "scalable-webapp" } }
