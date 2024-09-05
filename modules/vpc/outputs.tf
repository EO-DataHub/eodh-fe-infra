output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "db_subnets" {
  value = values(aws_subnet.db_subnets)[*].id
}
output "priv_subnets" {
  value = values(aws_subnet.priv_subnets)[*].id
}
output "pub_subnets" {
  value = values(aws_subnet.pub_subnets)[*].id
}
output "db_rtb_id" {
  value = var.create_db_subnets && length(aws_route_table.rtb_db_networks) > 0 ? aws_route_table.rtb_db_networks[0].id : null
}

output "pub_rtb_id" {
  value = aws_route_table.rtb_pub_networks[*].id
}

output "priv_rtb_id" {
  value = aws_route_table.rtb_priv_networks[*].id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}
output "igw_id" {
  value = aws_internet_gateway.igw[*].id
}
output "nat_public_ip" {
  value = [for eip in aws_eip.priv_nat_eip : eip.public_ip]
}