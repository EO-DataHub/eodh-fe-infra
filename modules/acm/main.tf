resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Name = var.domain_name
  }
  tags_all = {
    Name = var.domain_name
  }
  lifecycle {
    create_before_destroy = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}
resource "aws_route53_record" "cert-validation" {
  allow_overwrite = true
  depends_on      = [aws_acm_certificate.cert]
  zone_id         = var.r53_zone_id
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl             = 300
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
}