name = "scalable-app"
region = "ap-south-1"
azs = ["ap-south-1a","ap-south-1b"]
public_subnet_cidrs  = ["10.0.0.0/24","10.0.1.0/24"]
private_subnet_cidrs = ["10.0.10.0/24","10.0.11.0/24"]
tags = { Environment = "prod", Owner = "platform-team" }
