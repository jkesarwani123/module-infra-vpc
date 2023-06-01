# Create one VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(var.tags, { Name = "${var.env}-vpc"})
}

# Create 2 subnets each for public, web, app and db
module "subnets" {
  source = "./subnets"
  for_each = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value["cidr_block"]
  name = each.value["name"]
  azs = each.value["azs"]
  tags = var.tags
  env = var.env
}

# Create one Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, { Name = "${var.env}-igw"})
}

# Allocate Elastic IP for NAT Gateway
resource "aws_eip" "ngw" {
  count = length(var.subnets["public"].cidr_block)
  tags  = merge(var.tags, { Name = "${var.env}-ngw" })
}

# Create 2 NAT Gateways for the 2 public subnets
resource "aws_nat_gateway" "ngw" {
  count         = length(var.subnets["public"].cidr_block)
  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = module.subnets["public"].subnet_ids[count.index]

  tags = merge(var.tags, { Name = "${var.env}-ngw" })
}
#
#output "subnet_ids" {
#  value = module.subnets
#}

# Add Internet Gateway to public routes attached to public subnets only
resource "aws_route" "igw" {
  count         = length(module.subnets["public"].route_table_ids)
  route_table_id = module.subnets["public"].route_table_ids[count.index]
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Add NAT Gateway to private routes attached to app/web/db subnets only
#resource "aws_route" "ngw" {
#  count         = length(local.all_private_subnet_ids)
#  route_table_id = local.all_private_subnet_ids[count.index]
#  gateway_id = aws_nat_gateway.ngw.id
#  destination_cidr_block = "0.0.0.0/0"
#}

output "subnet" {
  value = module.subnets
}

output "ngw" {
  value = aws_nat_gateway.ngw
}