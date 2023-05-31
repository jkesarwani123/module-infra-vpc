resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(var.tags, { Name = "${var.env}-vpc"})
}

module "subnets" {
  source = "./subnets"
  for_each = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value["cidr_block"]
  name = each.value["name"]
  tags = var.tags
  env = var.env
}