/*module "ecs_service_dev" {
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
  listener          = module.alb.listener_443
  rule_priority     = "1"
  domain            = aws_route53_zone.test.name
}*/
module "ecs_service" {
  source = "../modules/ecs_services"
  for_each = {
    for env_name, env_data in var.environments : env_name => env_data
    if env_data.create_ecs == true
  }

  ecs_cluster_arn   = module.ecs.ecs_cluster_arn[each.key]
  env               = each.value.name
  cpu_allocation    = 256
  memory_allocation = 512
  service_name      = "ac-api"
  service_port      = "8000"
  region            = var.region
  vpc_id            = module.vpc_tests.vpc_id
  subnet_ids        = module.vpc_tests.priv_subnets
  listener          = module.alb.listener_443
  # Increment rule_priority by the position of the environment in the list
  rule_priority = 1 + index(tolist(keys(var.environments)), each.key)

  domain = aws_route53_zone.test.name
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
  alb_cert_arn    = module.acm_alb.acm_cert_arn
}
