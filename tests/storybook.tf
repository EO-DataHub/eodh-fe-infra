resource "aws_wafv2_ip_set" "allowed_ips" {
  name               = "storybook_allowed_ips"
  scope              = "CLOUDFRONT"
  description        = "storybook_allowed_ips"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ips
}
import {
  to = aws_wafv2_ip_set.allowed_ips
  id = "6f35ef9b-6404-4719-b821-7b438a732a6e/storybook_allowed_ips/CLOUDFRONT"
}
resource "aws_wafv2_web_acl" "storybook_allowed_ips" {
  name        = "storybook_allowed_ips"
  description = "storybook_allowed_ips"
  scope       = "CLOUDFRONT"

  default_action {
    block {
      custom_response {
        response_code = 403
      }
    }
  }
  rule {
    name     = "storybook_allowed_ips"
    priority = 0
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "storybook_allowed_ips"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "storybook_allowed_ips"
    sampled_requests_enabled   = true
  }
}



import {
  to = aws_wafv2_web_acl.storybook_allowed_ips
  id = "7e33cd3c-eac4-4563-b17a-3b95e8d3a79f/storybook_allowed_ips/CLOUDFRONT"
}