resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(var.tags, { Name = "${var.env}-vpc"})
}