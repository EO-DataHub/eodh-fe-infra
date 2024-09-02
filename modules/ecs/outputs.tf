output "asg_name" {
  value = aws_autoscaling_group.ecs_asg.name
}
output "fileuoploader2s3" {
  value = aws_iam_role.fileuploader2s3-role.arn
}