resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "vpc_${var.vpc_name}"
    environment = var.env
  }
}
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  for_each   = var.secondary_cidr != null ? { "secondary_cidr" = var.secondary_cidr } : {}
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value
}

resource "aws_subnet" "pub_subnets" {
  for_each                = var.create_pub_subnets ? var.pub_subnets : {}
  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name        = "pub_${each.value["az"]}"
    environment = var.vpc_name
  }
}
resource "aws_route_table" "rtb_pub_networks" {
  count      = var.create_pub_subnets ? 1 : 0
  depends_on = [aws_subnet.pub_subnets]
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "pub_${var.vpc_name}"
  }
}
resource "aws_route_table_association" "rtb_pub_association" {
  depends_on     = [aws_route_table.rtb_pub_networks, aws_subnet.pub_subnets]
  for_each       = var.create_pub_subnets ? var.pub_subnets : {}
  route_table_id = aws_route_table.rtb_pub_networks[0].id
  subnet_id      = aws_subnet.pub_subnets[each.key].id
}
resource "aws_internet_gateway" "igw" {
  depends_on = [aws_vpc.vpc, aws_subnet.pub_subnets]
  count      = var.create_pub_subnets ? 1 : 0
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "igw_${var.vpc_name}"
  }
}
resource "aws_route" "pub_route_to_0_0_0_0" {
  depends_on             = [aws_route_table.rtb_pub_networks, aws_internet_gateway.igw]
  for_each               = var.create_pub_subnets ? var.pub_subnets : {}
  route_table_id         = aws_route_table.rtb_pub_networks[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}
resource "aws_subnet" "priv_subnets" {
  for_each                = var.create_priv_subnets ? var.priv_subnets : {}
  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name        = "priv_${each.value["az"]}"
    environment = var.vpc_name
  }
}
resource "aws_eip" "priv_nat_eip" {
  count  = var.nat-gw == "yes" && var.nat_balancing == true ? length(var.priv_subnets) : var.nat-gw == "yes" ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "natgw_${var.vpc_name}"
  }
}

locals {
  nat_eip_ids = { for idx, eip in aws_eip.priv_nat_eip : idx => eip.id }
}
resource "aws_nat_gateway" "natgw" {
  count         = var.nat-gw == "yes" && var.nat_balancing == true ? length(var.priv_subnets) : var.nat-gw == "yes" ? 1 : 0
  allocation_id = local.nat_eip_ids[count.index]
  subnet_id     = values(aws_subnet.pub_subnets)[count.index].id # pub subnets
  tags = {
    Name = "natgw_${count.index + 1}"
  }
}

resource "aws_route_table" "rtb_priv_networks" {
  count  = var.nat_balancing == true ? length(var.priv_subnets) : 1
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "priv_${var.vpc_name}_${count.index + 1}"
  }
}

resource "aws_route" "priv_routes" {
  count                  = var.nat-gw == "yes" ? (var.nat_balancing == true ? length(var.priv_subnets) : 1) : 0
  route_table_id         = aws_route_table.rtb_priv_networks[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat-gw == "yes" ? aws_nat_gateway.natgw[count.index].id : null
}

resource "aws_route_table_association" "private_subnet_associations" {
  count          = var.nat_balancing == true ? length(aws_subnet.priv_subnets) : 0
  subnet_id      = aws_subnet.priv_subnets[keys(aws_subnet.priv_subnets)[count.index]].id
  route_table_id = aws_route_table.rtb_priv_networks[count.index].id
}

resource "aws_route_table_association" "default_subnet_associations" {
  count          = var.nat_balancing == true ? 0 : length(aws_subnet.priv_subnets)
  subnet_id      = aws_subnet.priv_subnets[keys(aws_subnet.priv_subnets)[count.index]].id
  route_table_id = aws_route_table.rtb_priv_networks[0].id # <------- Using route table with ID 0 !!!!!!!!!!
}


resource "aws_subnet" "db_subnets" {
  for_each                = var.create_db_subnets ? var.db_subnets : {}
  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name        = "db_${each.value["az"]}"
    environment = var.vpc_name
  }
}
resource "aws_route_table" "rtb_db_networks" {
  depends_on = [aws_subnet.db_subnets]
  for_each   = var.create_db_subnets ? var.db_subnets : {}
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "db_${var.vpc_name}"
  }
}
resource "aws_route_table_association" "rtb_db_association" {
  depends_on     = [aws_route_table.rtb_db_networks, aws_subnet.db_subnets]
  for_each       = var.create_db_subnets ? var.db_subnets : {}
  route_table_id = var.env == "dev" ? aws_route_table.rtb_pub_networks[0].id : aws_route_table.rtb_db_networks[0].id //aws_route_table.rtb_db_networks.id
  subnet_id      = aws_subnet.db_subnets[each.key].id
}