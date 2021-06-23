#
# Set up VPC
#
resource "aws_vpc" "splunk_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy = "default"

  tags = {
    Name = "My VPC"
  }
}
######
#
# Network
#
######
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.splunk_vpc.id

  tags = {
    Name          = "${var.tag_name}-gateway"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Contact     = var.tag_contact
    X-Application = var.tag_application
    X-TTL         = var.tag_ttl
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.splunk_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.splunk_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${var.aws_availability_zone_a}"
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.splunk_vpc.id
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${var.aws_availability_zone_b}"
}

resource "aws_route_table" "splunk_vpc_public" {
    vpc_id = aws_vpc.splunk_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
        Name = "Public Subnets Route Table for My VPC"
    }
}

resource "aws_route_table_association" "public_a" {
    subnet_id = aws_subnet.public_a.id
    route_table_id = aws_route_table.splunk_vpc_public.id
}

resource "aws_route_table_association" "public_b" {
    subnet_id = aws_subnet.public_b.id
    route_table_id = aws_route_table.splunk_vpc_public.id
}

#
# Security Groups
#
resource "aws_security_group" "ssh" {
  name        = "learn_splunk_ssh"
  description = "Used in a terraform exercise"
  vpc_id      = aws_vpc.splunk_vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "splunk" {
  name        = "learn_splunk"
  description = "Used in a terraform exercise"
  vpc_id      = aws_vpc.splunk_vpc.id

  # Allow inbound HTTP connection from all
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}