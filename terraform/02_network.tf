# Production VPC
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Public subnets
resource "aws_subnet" "public_1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.default.id
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${local.name}-public-1"
  }
}
resource "aws_subnet" "public_2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.default.id
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${local.name}-public-2"
  }
}

# Private subnets
resource "aws_subnet" "private_1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.default.id
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${local.name}-private-1"
  }
}
resource "aws_subnet" "private_2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.default.id
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${local.name}-private-2"
  }
}

# Route tables for the subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.name}-public"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.name}-private"
  }
}

# Associate the newly created route tables to the subnets
resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1.id
  
}
resource "aws_route_table_association" "public_2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_2.id
}
resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_1.id
}
resource "aws_route_table_association" "private_2" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_2.id
}

# Elastic IP
resource "aws_eip" "default" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  depends_on                = [aws_internet_gateway.default]
}

# NAT gateway
resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.default.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_eip.default]
}
resource "aws_route" "nat-gateway" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Route the public subnet traffic through the Internet Gateway
resource "aws_route" "public-internet-gateway" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}
