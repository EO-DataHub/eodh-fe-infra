output "cf_domain_name" {
  value = aws_cloudfront_distribution.cf_front.domain_name
}
output "cf_zone_id" {
  value = aws_cloudfront_distribution.cf_front.hosted_zone_id
}
output "acm_cert_arn" {
  value = aws_acm_certificate.cert.arn
}