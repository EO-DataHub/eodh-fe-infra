
module "front" {
  depends_on      = [aws_route53_zone.main]
  for_each        = var.environments
  source          = "../modules/front"
  domain          = aws_route53_zone.main.name
  web_acl_arn     = each.value.name == "storybook" ? aws_wafv2_web_acl.storybook_allowed_ips.arn : null
  env             = each.value.name
  route53_zone_id = aws_route53_zone.main.id
  api_alb         = module.alb.alb_name
}
