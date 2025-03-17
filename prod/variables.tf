data "aws_caller_identity" "current" {}
variable "environments" {
  type = map(any)
  default = {
    prod = {
      name       = "prod"
      create_ecs = true
    },
  }
}
variable "allowed_ips" {}