variable "region" {
  default = "us-east-1"
}
provider "aws" {
  region = var.region
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
  cloud {
    organization = "EODH"
    workspaces {
      name = "prod-eodh-fe-infra"
    }
  }
}