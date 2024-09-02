data "aws_ami" "aws_optimized_ecs" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"] # AWS
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster-name
}
output "ecs-cluster-name" {
  value = aws_ecs_cluster.cluster.name
}
output "ecs-cluster-arn" {
  value = aws_ecs_cluster.cluster.arn
}
resource "aws_iam_instance_profile" "ecsprofile" {
  name = "ecsprofile"
  role = aws_iam_role.ecsrole.name
}
resource "aws_iam_role" "ecsrole" {
  name = "ecsrole-${var.cluster-name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}
resource "aws_iam_policy_attachment" "ecspolicy-attach" {
  name       = "ecspolicyattach"
  roles      = [aws_iam_role.ecsrole.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_launch_template" "ecs-launch-tmpl" {
  name                   = "ecs-tmp-${var.cluster-name}"
  update_default_version = true
  image_id               = data.aws_ami.aws_optimized_ecs.id
  vpc_security_group_ids = [aws_security_group.ecs-cluster-instances-sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecsprofile.name
  }
  instance_type = var.instance-type
  user_data = base64encode(
    <<EOF
                  #!/bin/bash
                  echo "ECS_CLUSTER=${var.cluster-name}" >> /etc/ecs/ecs.config
                  EOF
  )
}
resource "aws_security_group" "ecs-cluster-instances-sg" {
  vpc_id      = var.vpc-id
  name        = "ecs-cluster-instances-sg"
  description = "ecs-cluster-sg"
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name = "pub-alb-for-ecs-${var.cluster-name}-sg"
  }
}
output "ecs-instances-sg" {
  value = aws_security_group.ecs-cluster-instances-sg.id
}
resource "aws_security_group_rule" "alb-to-ecs-instances" {
  description              = "alb-to-ecs-instances"
  security_group_id        = aws_security_group.ecs-cluster-instances-sg.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg-pub-alb.id
  type                     = "ingress"
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "ecs-asg-${var.cluster-name}"
  min_size            = var.asg_min_nodes
  max_size            = var.asg_max_nodes
  desired_capacity    = var.asg_desired_nodes
  vpc_zone_identifier = var.priv-ecs-subnets
  capacity_rebalance  = true
  target_group_arns   = [aws_alb_target_group.alb-tg-ecs.arn]
  launch_template {
    id      = aws_launch_template.ecs-launch-tmpl.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "ecs-asg-${var.cluster-name}"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "sg-pub-alb" {
  vpc_id      = var.vpc-id
  name        = "pub-alb-for-${var.cluster-name}-sg"
  description = "pub-alb-for-${var.cluster-name}-sg"
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name = "pub-alb-for-ecs-${var.cluster-name}-sg"
  }
}
resource "aws_lb" "ecs-alb" {
  name                       = "ecs-pub-${var.cluster-name}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg-pub-alb.id]
  subnets                    = var.pub-alb-subnets
  enable_deletion_protection = false
}
output "ecs-alb-id" {
  value = aws_lb.ecs-alb.id
}
output "ecs-alb-name" {
  value = aws_lb.ecs-alb.dns_name
}
resource "aws_lb_listener" "ecs-listener-80" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "ecs-listener-443" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_cert_arn
  default_action {
    type             = "fixed-response"
    target_group_arn = aws_alb_target_group.alb-tg-ecs.arn
    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}
output "ecs-listener-443" {
  value = aws_lb_listener.ecs-listener-443.arn
}

resource "aws_alb_target_group" "alb-tg-ecs" {
  name     = "ecs-tg-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id
}
output "sg-pub-alb-id" {
  value = aws_security_group.sg-pub-alb.id
}
//iam roles fileuploader
resource "aws_iam_role" "fileuploader2s3-role" {
  name = "${var.env-name}-fileuploader2s3"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "fileuploader2s3-policy" {
  name        = "${var.env-name}-fileuploader2s3-policy"
  description = "${var.env-name}-fileuploader2s3-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "fileuploader2s3",
            "Effect": "Allow",
            "Action": [
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket"
            ],
            "Resource": [
            "${var.media_bucket_arn}",
            "${var.media_bucket_arn}/*"
]
        }
    ]
}
  EOF
  tags_all = {
    Name = "${var.env-name}-fileuploader2s3-role"
  }
  tags = {
    Name = "${var.env-name}-fileuploader2s3-role"
  }
}

resource "aws_iam_role_policy_attachment" "fileuploader2s3-attach" {
  policy_arn = aws_iam_policy.fileuploader2s3-policy.arn
  role       = aws_iam_role.fileuploader2s3-role.name
}
//iam roles ecstaskexecution
resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${var.env-name}-ecs-task-execution-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}
output "ecs-task-execution-role" {
  value = aws_iam_role.ecs-task-execution-role.arn
}
resource "aws_iam_policy" "ecs-secret-read-policy" {
  name        = "${var.env-name}-ecs-secret-read-policy"
  description = "${var.env-name}-ecs-secret-read-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EcsSecretRead",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetRandomPassword",
                "secretsmanager:ListSecrets",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": [
              "${var.sm-arn-glasscad-db}",
              "${var.sm-arn-mq}",
              "${var.sm-arn-elasticache}"
            ]
        }
    ]
}
  EOF
  tags_all = {
    Name = "${var.env-name}-ecs-secret-read-role"
  }
  tags = {
    Name = "${var.env-name}-ecs-secret-read-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs-secret-read-attach" {
  policy_arn = aws_iam_policy.ecs-secret-read-policy.arn
  role       = aws_iam_role.ecs-task-execution-role.name
}
resource "aws_iam_role_policy_attachment" "task-execution-attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs-task-execution-role.name
}
resource "aws_route53_record" "api-ecs" {
  zone_id = var.route53-zone-id
  name    = "api.${var.route53-zone-name}"
  type    = "A"
  alias {
    name                   = aws_lb.ecs-alb.dns_name
    zone_id                = aws_lb.ecs-alb.zone_id
    evaluate_target_health = false
  }
}