/*
resource "aws_ecs_cluster" "cluster" {
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  service_connect_defaults {
    namespace = aws_service_discovery_private_dns_namespace.qa.arn
  }
  name = each.value.name
}
resource "aws_service_discovery_private_dns_namespace" "qa" {
  name        = "qa"
  vpc         = module.vpc_tests.vpc_id
}
*/
module "ecs_service_dev" {
  source            = "../modules/ecs_services"
  ecs_cluster_arn   = module.ecs.ecs_cluster_arn["dev"]
  env               = "dev"
  cpu_allocation    = 256
  memory_allocation = 512
  service_name      = "ac_api"
  ecr_name          = "ac-api"
  service_port      = "8000"
  region            = var.region
  vpc_id            = module.vpc_tests.vpc_id
  subnet_ids        = module.vpc_tests.pub_subnets
}
/*import {
  to = aws_service_discovery_private_dns_namespace.qa
  id = "ns-3cx56mc2k4zgmete:${module.vpc_tests.vpc_id}"
}*/
module "ecs" {
  source       = "../modules/ecs"
  environments = var.environments
  vpc_id       = module.vpc_tests.vpc_id
}