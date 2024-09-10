resource "aws_service_discovery_private_dns_namespace" "ns" {
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  name = each.value.name
  vpc  = var.vpc_id
}
resource "aws_ecs_cluster" "cluster" {
  depends_on = [aws_service_discovery_private_dns_namespace.ns]
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  service_connect_defaults {
    namespace = aws_service_discovery_private_dns_namespace.ns[each.value.name].arn
  }
  name = each.value.name
}
