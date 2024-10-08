resource "aws_security_group" "sg_pub_alb" {
  vpc_id      = var.vpc_id
  name        = "alb_${var.name}_sg"
  description = "alb_${var.name}_sg"
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name = "alb_${var.name}_sg"
  }
}
resource "aws_security_group_rule" "http" {
  depends_on        = [aws_security_group.sg_pub_alb]
  description       = "http"
  security_group_id = aws_security_group.sg_pub_alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}
resource "aws_security_group_rule" "https" {
  depends_on        = [aws_security_group.sg_pub_alb]
  description       = "https"
  security_group_id = aws_security_group.sg_pub_alb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}
resource "aws_lb" "alb" {
  depends_on                 = [aws_security_group_rule.http, aws_security_group_rule.https]
  name                       = var.name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg_pub_alb.id]
  subnets                    = var.pub_alb_subnets
  enable_deletion_protection = false
}
resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.alb.arn
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
resource "aws_lb_listener" "listener_443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_cert_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}