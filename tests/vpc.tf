module "vpc" {
  source                             = "terraform-aws-modules/vpc/aws"
  name                               = "ukri"
  single_nat_gateway                 = true
  enable_nat_gateway                 = true
  cidr                               = "10.104.8.0/23"
  azs                                = ["us-east-1a", "us-east-1b"]           # Availability Zones to use
  public_subnets                     = ["10.104.8.0/26", "10.104.8.64/26"]    # Public subnet CIDRs
  private_subnets                    = ["10.104.8.128/26", "10.104.8.192/26"] # Private subnet CIDRs
  create_database_subnet_route_table = false
}