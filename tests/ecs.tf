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
  listener          = module.alb.listener_443
  rule_priority     = "1"
  domain            = aws_route53_zone.test.name
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
import {
  to = module.ecs_service_dev.aws_lb_listener_rule.rule
  id = "arn:aws:elasticloadbalancing:us-east-1:058264362748:listener-rule/app/ac-api/863735d9740aa920/38c658d58e3fe8bd/1caeadb4b8e67666"
}