resource "aws_cloudwatch_log_group" "log_group" {
  retention_in_days = 7
  name              = "/ecs/${var.service_name}"
  tags = {
    Name = "${var.service_name}_lg"

  }
}
resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.service_name
  task_role_arn            = var.task_role_arn
  network_mode             = "bridge"
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = true
  container_definitions = jsonencode([
    {
      name : var.service_name,
      image : "${var.ecr_repo}/${var.service_name}:latest", //image : "${var.ecr_repo}/${var.service_name}:${var.env}",
      cpu : var.cpu_allocation,
      memoryReservation : var.memory_allocation,
      essential : true,
      portMappings : [
        {
          containerPort : tonumber(var.service_port),
          hostPort : 0,
          protocol : "tcp"
        }
      ],
      logConfiguration : {
        logDriver : "awslogs",
        secretOptions : null,
        options : {
          "awslogs-group" : aws_cloudwatch_log_group.log_group.name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "ecs"
        }
      },
      environment : var.ecs_td_envs,
      secrets : var.ecs_td_secrets
    }
  ])
  tags = {
    Name = var.service_name
  }
}
/*resource "aws_lb_target_group" "service_tg" {
  name                 = var.service_name
  deregistration_delay = 30
  port                 = 80
  protocol             = "HTTP"
  target_type          = "instance"
  health_check {
    path                = "/${var.service_name}${var.healthcheck_path}"
    protocol            = "HTTP"
    healthy_threshold   = 2
    timeout             = 30
    interval            = 31
    unhealthy_threshold = 10
    matcher             = "200"
  }
  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  vpc_id = var.vpc_id
}

resource "aws_lb_listener_rule" "rule" {

  listener_arn = var.listener
  priority     = var.rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg.arn
  }
  condition {
    path_pattern {
      values = ["/${var.service_name}/*"]
    }
  }
  tags = {
    Name = var.service_name
  }
}

 */
resource "aws_ecs_service" "service" {
  //  depends_on                         = [aws_lb_target_group.service_tg, aws_lb_listener_rule.rule]
  name                               = var.service_name
  cluster                            = var.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.task_definition.arn
  desired_count                      = var.desired_task_count
  wait_for_steady_state              = false
  health_check_grace_period_seconds  = 360
  enable_ecs_managed_tags            = true
  deployment_minimum_healthy_percent = 100
  deployment_controller {
    type = "ECS"
  }
  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }
  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }
  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }

  /*  load_balancer {
    target_group_arn = aws_lb_target_group.service_tg.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }*/
}