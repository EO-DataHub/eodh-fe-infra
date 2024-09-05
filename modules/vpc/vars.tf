variable "vpc-cidr" {}
variable "env" {}
variable "pub_subnets" { default = null }
variable "priv_subnets" { default = null }
variable "db_subnets" { default = null }
variable "nat-gw" { default = "no" }
variable "vpc_name" {}
variable "create_db_subnets" { default = false }
variable "create_pub_subnets" { default = false }
variable "create_priv_subnets" { default = false }
variable "nat_balancing" { default = false }
variable "secondary_cidr" { default = null }
