output "ecs_cluster_arn" {
  value = {
    for key, cluster in aws_ecs_cluster.cluster : key => cluster.arn
  }
}