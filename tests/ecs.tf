resource "aws_ecs_cluster" "cluster" {
  for_each = {
    for key, env in var.environments : key => env
    if env.create_ecs == true
  }

  name = each.value.name
}