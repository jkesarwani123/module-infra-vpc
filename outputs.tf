output "subnets" {
  value = module.subnets
}

output "vpc_id" {
  value = aws_vpc.main.id
}

#
#output "subnet_ids" {
#  value = module.subnets
#}
#
#output "subnet" {
#  value = module.subnets
#}
#
#output "ngw" {
#  value = aws_nat_gateway.ngw
#}