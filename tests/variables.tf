data "aws_caller_identity" "current" {}
variable "environments" {
  type = map(any)
  default = {
    dev = {
      name       = "dev"
      create_ecs = true
    },
    qa = {
      name       = "qa"
      create_ecs = true
    },
    staging = {
      name       = "staging"
      create_ecs = true
    },
    storybook = {
      name       = "storybook"
      create_ecs = false
    }
  }
}
variable "allowed_ips" {}