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
/*module "vpc" {
  source                             = "terraform-aws-modules/vpc/aws"
  name                               = "ukri"
  single_nat_gateway                 = true
  enable_nat_gateway                 = true
  cidr                               = "10.104.8.0/23"
  azs                                = ["us-east-1a", "us-east-1b"] # Availability Zones to use
  public_subnets                     = ["10.104.8.0/26", "10.104.8.64/26"]        # Public subnet CIDRs
  private_subnets                    = ["10.104.8.128/26", "10.104.8.192/26"]     # Private subnet CIDRs
  create_database_subnet_route_table = false
}
import {
  to = module.vpc.aws_vpc.this[0]
  id = "vpc-06ae0aa5b3d384033"
}
import {
  to = module.vpc.aws_subnet.public[0]
  id = "subnet-04d52457b6fa9a47b"
}
import {
  to = module.vpc.aws_subnet.public[1]
  id = "subnet-04695473084df00ed"
}
import {
  to = module.vpc.aws_subnet.private[0]
  id = "subnet-00c843f7ccf360dd1"
}
import {
  to = module.vpc.aws_subnet.private[1]
  id = "subnet-05ea3e0d572613222"
}
import {
  to = module.vpc.aws_route_table.public[0]
  id = "rtb-0e97cc68a2a242f9b"
}
import {
  to = module.vpc.aws_route_table.private[0]
  id = "rtb-03137bfb6d85e7629"
}
import {
  to = module.vpc.aws_route_table_association.private[0]
  id = "subnet-00c843f7ccf360dd1/rtb-03137bfb6d85e7629"
}
import {
  to = module.vpc.aws_route_table_association.private[1]
  id = "subnet-05ea3e0d572613222/rtb-03137bfb6d85e7629"
}
import {
  to = module.vpc.aws_route_table_association.public[0]
  id = "subnet-04d52457b6fa9a47b/rtb-0e97cc68a2a242f9b"
}
import {
  to = module.vpc.aws_route_table_association.public[1]
  id = "subnet-04695473084df00ed/rtb-0e97cc68a2a242f9b"
}
import {
  to = module.vpc.aws_nat_gateway.this[0]
  id = "nat-07340683f218e627b"
}
import {
  to = module.vpc.aws_internet_gateway.this[0]
  id = "igw-02808f6a1758a202c"
}
import {
  to = module.vpc.aws_eip.nat[0]
  id = "eipalloc-00736fb313fb3c4af"
}
import {
  to = module.vpc.aws_default_network_acl.this[0]
  id = "acl-0007409f442a6a593"
}
import {
  to = module.vpc.aws_route.public_internet_gateway[0]
  id = "rtb-0e97cc68a2a242f9b_0.0.0.0/0"
}
import {
  to = module.vpc.aws_route.private_nat_gateway[0]
  id = "rtb-03137bfb6d85e7629_0.0.0.0/0"
}*/
/*import {
  to = module.vpc.aws_default_route_table.default[0]
  id = "rtb-0713b17929707712b"
}*/
