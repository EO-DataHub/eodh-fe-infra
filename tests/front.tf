variable "environments" {
  type = map(any)
  default = {
    dev = {
      name = "dev"
    },
    qa = {
      name = "qa"
    },
    staging = {
      name = "staging"
    },
    storybook = {
      name = "storybook"
    }
  }
}

module "front" {
  depends_on      = [aws_route53_zone.test]
  for_each        = var.environments
  source          = "../modules/front"
  account_id      = data.aws_caller_identity.current.account_id
  domain          = aws_route53_zone.test.name
  web_acl_arn     = each.value.name == "storybook" ? aws_wafv2_web_acl.storybook_allowed_ips.arn : null
  env             = each.value.name
  route53_zone_id = aws_route53_zone.test.id
}
