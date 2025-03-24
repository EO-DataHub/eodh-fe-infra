module "front" {
  depends_on      = [aws_route53_zone.main]
  for_each        = var.environments
  source          = "../modules/front"
  domain          = aws_route53_zone.main.name
  env             = each.value.name
  route53_zone_id = aws_route53_zone.main.id
  api_alb         = module.alb.alb_name
}
import {
  to = module.front["prod"].aws_s3_bucket.s3_cf
  id = "eopro.eodatahub.org.uk"
}