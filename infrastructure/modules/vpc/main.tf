resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_support = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr_blocks)

  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets_cidr_blocks[count.index]
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-subnet-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr_blocks)

  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets_cidr_blocks[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.name_prefix}-subnet-private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr_blocks)

  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[count.index].id
}

resource "aws_security_group" "allow_all" {
  name = "${var.name_prefix}-allow-all-egress-sg"
  
  vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_all.id

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "allow_http_https_ingress" {
  name = "${var.name_prefix}-allow-http-ingress-sg"

  vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http_https_ingress.id

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow_http_https_ingress.id

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
}
