data "aws_caller_identity" "current" {}
variable "environments" {
  type = map(any)
  default = {
    dev = {
      name = "dev"
    },
    qa = {
      name = "qa"
    },
    staging = {
      name = "staging"
    },
    storybook = {
      name = "storybook"
    }
  }
}
variable "allowed_ips" {}