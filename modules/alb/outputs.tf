output "ecs_alb_id" {
  value = aws_lb.alb.id
}
output "ecs_alb_name" {
  value = aws_lb.alb.dns_name
}