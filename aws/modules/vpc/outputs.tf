output "vpc_id" {
  value = aws_vpc.programadev-vpc.id
}

output "subnet_ids" {
  value = aws_subnet.subnets[*].id
}