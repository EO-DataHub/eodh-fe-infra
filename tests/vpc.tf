module "vpc_tests" {
  source              = "../modules/vpc"
  vpc-cidr            = "10.104.8.0/23"
  env                 = "tests"
  vpc_name            = "ukri"
  nat-gw              = "yes"
  create_priv_subnets = true
  create_pub_subnets  = true
  pub_subnets = {
    subnet1 = {
      cidr = "10.104.8.0/26"
      az   = "us-east-1a"
    }
    subnet2 = {
      cidr = "10.104.8.64/26"
      az   = "us-east-1b"
    }
  }
  priv_subnets = {
    subnet1 = {
      cidr = "10.104.8.128/26"
      az   = "us-east-1a"
    }
    subnet2 = {
      cidr = "10.104.8.192/26"
      az   = "us-east-1b"
    }
  }
}