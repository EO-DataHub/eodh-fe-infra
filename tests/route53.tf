/*resource "aws_route53_zone" "test" {
  name = "lot2.eodatahub.org.uk"
  tags = {
    Name = "lot2.eodatahub.org.uk"
  }
}*/
resource "aws_route53_zone" "main" {
  name = "lot2.eodatahub.org.uk"
  tags = {
    Name = "lot2.eodatahub.org.uk"
  }
}
import {
  to = aws_route53_zone.main
  id = "Z0442300JCTJJLA8G2B5"
}