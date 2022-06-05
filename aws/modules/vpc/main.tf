resource "aws_vpc" "programadev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets" {
  count = var.quantity
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id = aws_vpc.programadev-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
    tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "programadev-igw" {
  vpc_id = aws_vpc.programadev-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "programadev-rtb" {
  vpc_id = aws_vpc.programadev-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.programadev-igw.id
  } 
  tags = {
    Name = "${var.prefix}-rtb"
  }
}

resource "aws_route_table_association" "programadev-rtb-association" {
  count = var.quantity
  route_table_id = aws_route_table.programadev-rtb.id
  subnet_id = aws_subnet.subnets.*.id[count.index]
}
