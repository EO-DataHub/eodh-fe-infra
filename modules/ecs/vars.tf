variable "cluster-name" {}
variable "env" {}
variable "env-name" {}
variable "instance-type" { default = "t3.micro" }
variable "priv-ecs-subnets" {}
variable "pub-alb-subnets" {}
variable "vpc-id" {}
variable "alb_cert_arn" {}
variable "sm-arn-glasscad-db" {}
variable "sm-arn-mq" {}
variable "sm-arn-elasticache" {}
variable "route53-zone-id" {}
variable "route53-zone-name" {}
variable "asg_min_nodes" { default = 1 }
variable "asg_max_nodes" {default = 3 }
variable "asg_desired_nodes" {default = 2}
variable "media_bucket_arn" {}
