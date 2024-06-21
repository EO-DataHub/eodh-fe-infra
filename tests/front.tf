variable "environments" {
  type    = list(string)
  default = ["dev", "qa", "staging"]
}

module "front" {
  depends_on = [aws_route53_zone.test]
  for_each        = toset(var.environments)
  source          = "../modules/front"
  account_id      = data.aws_caller_identity.current.account_id
  domain          = aws_route53_zone.test.name
  env             = each.key
  route53_zone_id = aws_route53_zone.test.id
}
