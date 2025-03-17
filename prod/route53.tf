resource "aws_route53_zone" "main" {
  name = "eopro.eodatahub.org.uk"
  tags = {
    Name = "eopro.eodatahub.org.uk"
  }
}
