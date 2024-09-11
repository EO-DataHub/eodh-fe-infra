variable "service_name" {}
//variable "execution_role" {}
variable "env" {}
variable "service_port" {}
variable "cpu_allocation" {}
variable "memory_allocation" {}
variable "ecr_repo" { default = "058264362748.dkr.ecr.us-east-1.amazonaws.com" }
variable "vpc_id" {}
variable "subnet_ids" {}
variable "assign_public_ip" { default = false }
variable "rule_priority" {}
variable "listener" {}
variable "ecs_cluster_arn" {}
variable "ecs_td_envs" { default = null }
variable "ecs_td_secrets" { default = null }
variable "repo_name" { default = null }
variable "task_role_arn" { default = null }
variable "desired_task_count" { default = 1 }
//variable "healthcheck_path" {default = "/actuator/health"}
variable "region" {}