resource "aws_acm_certificate" "cert" {
  domain_name               = var.env == "prod" ? var.domain : "${var.env}.${var.domain}"
  subject_alternative_names = [var.env == "prod" ? "*.${var.domain}" : "*.${var.env}.${var.domain}"]
  validation_method         = "DNS"

  tags = {
    Name = var.domain
  }
  tags_all = {
    Name = var.domain
  }
  lifecycle {
    create_before_destroy = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}
resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  depends_on      = [aws_acm_certificate.cert]
  zone_id         = var.route53_zone_id
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl             = 300
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
}
// S3 front
resource "aws_s3_bucket" "s3_cf" {
  bucket = "${var.env}.${var.domain}"
  tags = {
    Name = "${var.env}.${var.domain}"
  }
}
resource "aws_s3_bucket_policy" "cf_s3_acc" {
  bucket = aws_s3_bucket.s3_cf.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.s3_cf.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.cf_front.arn

          }
        }
      }
    ]
  })
}
resource "aws_cloudfront_cache_policy" "default_cf_cache_policy" {
  name        = "${var.env}_cache_pol"
  max_ttl     = 0
  default_ttl = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
resource "aws_cloudfront_origin_request_policy" "origin_request_cf_policy" {
  name = "${var.env}-origin-pol"
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewer"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
resource "aws_cloudfront_cache_policy" "order_policy" {
  name        = "${var.env}__cf_order_policy"
  max_ttl     = 31536000
  min_ttl     = 1
  default_ttl = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${var.env}-${var.domain}"
  description                       = "oac-${var.env}-${var.domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
data "aws_cloudfront_origin_request_policy" "AllViewer" {
  name = "Managed-AllViewer"
}
data "aws_cloudfront_cache_policy" "CachingDisabled" {
  name = "Managed-CachingDisabled"
}
resource "aws_cloudfront_distribution" "cf_front" {
  web_acl_id          = var.web_acl_arn
  comment             = var.env == "prod" ? var.domain : "${var.env}.${var.domain}"
  default_root_object = "index.html"
  origin {
    origin_id                = aws_s3_bucket.s3_cf.bucket_regional_domain_name
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = aws_s3_bucket.s3_cf.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }
  dynamic "origin" {
    for_each = var.env != "storybook" ? [var.api_alb] : []
    content {
      origin_id           = origin.value
      connection_attempts = 3
      connection_timeout  = 10
      domain_name         = origin.value
      custom_origin_config {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "match-viewer"
        origin_keepalive_timeout = 5
        origin_read_timeout      = 30
        origin_ssl_protocols     = ["TLSv1.2"]
      }
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  aliases         = [var.env == "prod" ? var.domain : "*.${var.env}.${var.domain}"]
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id        = aws_cloudfront_cache_policy.default_cf_cache_policy.id
    target_origin_id       = aws_s3_bucket.s3_cf.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.env != "storybook" ? [var.api_alb] : []
    content {
      path_pattern             = "/api/*"
      target_origin_id         = var.api_alb
      viewer_protocol_policy   = "redirect-to-https"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD", "OPTIONS"]
      cache_policy_id          = data.aws_cloudfront_cache_policy.CachingDisabled.id
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.AllViewer.id
      compress                 = false
      default_ttl              = 0
      max_ttl                  = 0
      min_ttl                  = 0
      smooth_streaming         = false
      trusted_signers          = []
      trusted_key_groups       = []
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Environment = var.env
  }
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
  /*  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 10
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 10
    response_code         = 200
    response_page_path    = "/index.html"
  }*/
}
resource "aws_route53_record" "front" {
  zone_id = var.route53_zone_id
  name    = var.env == "prod" ? var.domain : "${var.env}.${var.domain}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.cf_front.domain_name
    zone_id                = aws_cloudfront_distribution.cf_front.hosted_zone_id

  }
}