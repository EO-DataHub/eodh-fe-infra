module "ecs_service_dev" {
  source            = "../modules/ecs_services"
  ecs_cluster_arn   = module.ecs.ecs_cluster_arn["dev"]
  env               = "dev"
  cpu_allocation    = 256
  memory_allocation = 512
  service_name      = "ac-api"
  service_port      = "8000"
  region            = var.region
  vpc_id            = module.vpc_tests.vpc_id
  subnet_ids        = module.vpc_tests.priv_subnets
  listener      = module.alb.listener_80
  rule_priority = "1"
}
module "ecs" {
  source       = "../modules/ecs"
  environments = var.environments
  vpc_id       = module.vpc_tests.vpc_id
}
module "alb" {
  source          = "../modules/alb"
  name            = "ac-api"
  pub_alb_subnets = module.vpc_tests.pub_subnets
  vpc_id          = module.vpc_tests.vpc_id
}