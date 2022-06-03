resource "aws_vpc" "programadev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets" {
  count = 2
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
  count = 2
  route_table_id = aws_route_table.programadev-rtb.id
  subnet_id = aws_subnet.subnets.*.id[count.index]
}

resource "aws_security_group" "programadev-sg" {
  vpc_id = aws_vpc.programadev-vpc.id
  tags = {
    Name = "${var.prefix}-sg"
  }
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    prefix_list_ids = []
    protocol = "-1"
    to_port = 0
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}    
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "programadev-log" {
  name = "/aws/eks/${var.prefix}-${var.cluster_name}/cluster"
  retention_in_days = var.retention_days
}

resource "aws_eks_cluster" "cluster" {
  name = "${var.prefix}-${var.cluster_name}"
  role_arn = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["api","audit"]
  vpc_config {
    subnet_ids = aws_subnet.subnets[*].id
    security_group_ids = [aws_security_group.programadev-sg.id]
  }
  depends_on = [
    aws_cloudwatch_log_group.programadev-log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy
  ]
}

resource "aws_iam_role" "node" {
  name = "${var.prefix}-${var.cluster_name}-role-node"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}    
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSWorkerNodePolicy" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKS_CNI_Policy" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEC2ContainerRegistryReadOnly" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "node-1" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "node-1"
  node_role_arn = aws_iam_role.node.arn
  subnet_ids = aws_subnet.subnets[*].id
  instance_types = ["t3.micro"]
  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }
  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cluster-AmazonEC2ContainerRegistryReadOnly
  ]
}