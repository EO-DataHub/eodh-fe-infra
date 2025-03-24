resource "aws_route53_zone" "main" {
  name = "lot2.eodatahub.org.uk"
  tags = {
    Name = "lot2.eodatahub.org.uk"
  }
}
