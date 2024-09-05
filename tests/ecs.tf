resource "aws_ecs_cluster" "cluster" {
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  name = each.value.name
}
module "ecs_service_dev" {
  source            = "../modules/ecs_services"
  ecs_cluster_arn   = aws_ecs_cluster.cluster["dev"].arn
  env               = "dev"
  cpu_allocation    = 256
  memory_allocation = 512
  service_name      = "ac_api"
  service_port      = "8000"
  region            = var.region
  vpc_id            = module.vpc_tests.vpc_id
  subnet_ids        = module.vpc_tests.priv_subnets
}