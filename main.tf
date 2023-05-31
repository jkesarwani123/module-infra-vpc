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