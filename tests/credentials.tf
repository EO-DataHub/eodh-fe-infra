variable "region" {
  default = "us-east-1"
}
provider "aws" {
  region                   = var.region
  shared_config_files      = ["$HOME/.aws/credentials"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "ukri"
  default_tags {
    tags = {
      ManagedByTerraform = "YES"
    }
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53.0"
    }
  }
}
