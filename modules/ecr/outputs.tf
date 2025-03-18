output "ecr_arn" {
  value = { for repo in aws_ecr_repository.ecrs : repo.name => repo.arn }
}
output "ecr_url" {
  value = { for repo in aws_ecr_repository.ecrs : repo.name => repo.repository_url }
}
output "ecr_repositories" {
  value = { for repo in aws_ecr_repository.ecrs : repo.name => repo.name }
}