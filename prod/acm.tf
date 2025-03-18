module "acm_alb" {
  source      = "../modules/acm"
  domain_name = aws_route53_zone.main.name
  r53_zone_id = aws_route53_zone.main.zone_id
}