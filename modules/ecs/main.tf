resource "aws_service_discovery_http_namespace" "discovery_service" {
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  name = each.value.name

}
resource "aws_ecs_cluster" "cluster" {
  depends_on = [aws_service_discovery_http_namespace.discovery_service]
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.discovery_service[each.value.name].arn
  }
  name = each.value.name
}
resource "aws_ecs_cluster_capacity_providers" "default_providers" {
  depends_on = [aws_ecs_cluster.cluster]
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  cluster_name = aws_ecs_cluster.cluster[each.value.name].name

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  /*  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }*/
}