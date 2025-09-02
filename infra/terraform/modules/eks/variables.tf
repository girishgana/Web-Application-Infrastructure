variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "kubernetes_version" { type = string, default = "1.29" }
variable "desired_size" { type = number, default = 2 }
variable "min_size" { type = number, default = 2 }
variable "max_size" { type = number, default = 4 }
variable "instance_types" { type = list(string), default = ["t3.medium"] }
variable "oidc_thumbprint" { type = string, default = "9e99a48a9960b14926bb7f3b02e22da0afd10df6" }
variable "tags" { type = map(string), default = {} }
