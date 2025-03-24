
resource "aws_s3_bucket" "env_files" {
  bucket = "ukri-task-definition-variables"
}
resource "aws_s3_object" "env_files_dir" {
  depends_on = [aws_s3_bucket.env_files]
  for_each = {
    for env_name, env_data in var.environments : env_name => env_data
    if env_data.create_ecs == true
  }
  bucket = aws_s3_bucket.env_files.id
  key    = "${each.key}/envs.env"
  lifecycle {
    ignore_changes = [tags_all]
  }
}
module "alb" {
  source          = "../modules/alb"
  name            = "ac-api"
  pub_alb_subnets = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  alb_cert_arn    = module.acm_alb.acm_cert_arn
}
resource "aws_route53_record" "api" {
  depends_on = [module.alb]
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${aws_route53_zone.main.name}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = "dualstack.${module.alb.alb_name}"
    zone_id                = module.alb.alb_zone_id
  }
}

module "ecs_service" {
  depends_on = [aws_s3_bucket.env_files]
  source     = "../modules/ecs_services"
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
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnets
  listener          = module.alb.listener_443
  # Increment rule_priority by the position of the environment in the list
  rule_priority    = 1 + index(tolist(keys(var.environments)), each.key)
  alb_sg           = module.alb.alb_sg_id
  domain           = aws_route53_zone.main.name
  s3_arn_env_files = aws_s3_bucket.env_files.arn
}
module "ecs" {
  source       = "../modules/ecs"
  environments = var.environments
  vpc_id       = module.vpc.vpc_id
}

