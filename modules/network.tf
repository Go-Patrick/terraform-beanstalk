# Set up VPC
resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test-vpc"
  }
}

# Set up SUBNETS
resource "aws_subnet" "test_public_1" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.test_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name = "test-public-1"
  }
}

resource "aws_subnet" "test_public_2" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.test_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"

  tags = {
    Name = "test-public-2"
  }
}

resource "aws_subnet" "test_lb_1" {
  cidr_block              = "10.0.3.0/24"
  vpc_id                  = aws_vpc.test_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name = "test-lb-1"
  }
}

resource "aws_subnet" "test_lb_2" {
  cidr_block              = "10.0.4.0/24"
  vpc_id                  = aws_vpc.test_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"

  tags = {
    Name = "test-lb-2"
  }
}

#Set up GATEWAY
resource "aws_internet_gateway" "test_gateway" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test-gw"
  }
}

# Set up route table
resource "aws_route_table" "test_public" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test-rt"
  }
}

resource "aws_route" "test_route" {
  route_table_id = aws_route_table.test_public.id

  gateway_id = aws_internet_gateway.test_gateway.id

  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "test_ass_1" {
  route_table_id = aws_route_table.test_public.id
  subnet_id      = aws_subnet.test_lb_1.id
}

resource "aws_route_table_association" "test_ass_2" {
  route_table_id = aws_route_table.test_public.id
  subnet_id      = aws_subnet.test_lb_2.id
}

resource "aws_route_table_association" "test_ass_3" {
  route_table_id = aws_route_table.test_public.id
  subnet_id      = aws_subnet.test_public_1.id
}

resource "aws_route_table_association" "test_ass_4" {
  route_table_id = aws_route_table.test_public.id
  subnet_id      = aws_subnet.test_public_2.id
}

# Set up security group
resource "aws_security_group" "test_bean_sg" {
  name   = "test-bean-sg"
  vpc_id = aws_vpc.test_vpc.id

  ingress {
    description      = "Allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all out traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "test-bean-sg"
  }
}

