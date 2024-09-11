resource "aws_cloudwatch_log_group" "log_group" {
  retention_in_days = 7
  name              = "/ecs/${var.env}_${var.service_name}"
  tags = {
    Name = "${var.env}_${var.service_name}_lg"

  }
}
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.env}_${var.service_name}_ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "task_definition" {
  depends_on               = [aws_iam_role.ecs_task_execution_role]
  family                   = "${var.env}_${var.service_name}"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = true
  cpu                      = var.cpu_allocation
  memory                   = var.memory_allocation
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name : "${var.env}_${var.service_name}",
      image : "${var.ecr_repo}/${var.service_name}:latest", //image : "${var.ecr_repo}/${var.service_name}:${var.env}",
      cpu : var.cpu_allocation,
      memoryReservation : var.memory_allocation,
      essential : true,
      portMappings : [
        {
          containerPort : tonumber(var.service_port),
          hostPort : tonumber(var.service_port),
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
    Name = "${var.env}_${var.service_name}"
  }
}
resource "aws_lb_target_group" "service_tg" {
  name                 = var.service_name
  deregistration_delay = 30
  port                 = 8000
  protocol             = "HTTP"
  target_type          = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    timeout             = 10
    interval            = 31
    unhealthy_threshold = 10
    matcher             = "200-499"
  }
  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  vpc_id = var.vpc_id
}
/*
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
  depends_on                         = [aws_security_group.task_sg]
  name                               = var.service_name
  cluster                            = var.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.task_definition.arn
  desired_count                      = var.desired_task_count
  wait_for_steady_state              = false
  enable_ecs_managed_tags            = true
  deployment_minimum_healthy_percent = 100
  //launch_type                        = "FARGATE"
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base = 1
    weight = 100

  }
  deployment_controller {
    type = "ECS"
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  /*
  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }
  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }*/
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.task_sg.id]
    assign_public_ip = var.assign_public_ip
  }
    load_balancer {
    target_group_arn = aws_lb_target_group.service_tg.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }
}
resource "aws_security_group" "task_sg" {
  vpc_id = var.vpc_id
  name   = "${var.env}_${var.service_name}_sg"
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name = "${var.env}_${var.service_name}_sg"
  }
}