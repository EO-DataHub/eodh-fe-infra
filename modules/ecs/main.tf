resource "aws_service_discovery_service" "discovery_service" {
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  name = each.value.name

}
resource "aws_ecs_cluster" "cluster" {
  depends_on = [aws_service_discovery_service.discovery_service]
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  service_connect_defaults {
    namespace = aws_service_discovery_service.discovery_service[each.value.name].arn
  }
  name = each.value.name
}
