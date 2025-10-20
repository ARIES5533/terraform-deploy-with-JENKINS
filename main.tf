# --- VPC ---
resource "aws_vpc" "infra-jenkins" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "infra-vpc"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "infra-jenkins" {
  vpc_id = aws_vpc.infra-jenkins.id

  tags = {
    Name = "infra-igw-jenkins"
  }
}

# --- Public Subnet ---
resource "aws_subnet" "public-jenkins" {
  vpc_id                  = aws_vpc.infra-jenkins.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "public-subnet-jenkins"
  }
}

# --- Route Table & Route ---
resource "aws_route_table" "public-jenkins" {
  vpc_id = aws_vpc.infra-jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infra-jenkins.id
  }

  tags = {
    Name = "public-route-table-jenkins"
  }
}

# --- Route Table Association ---
resource "aws_route_table_association" "public_assoc-jenkins" {
  subnet_id      = aws_subnet.public-jenkins.id
  route_table_id = aws_route_table.public-jenkins.id
}

# --- Security Group ---
resource "aws_security_group" "ec2_sg-jenkins" {
  name        = "ec2-sg-jenkins"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.infra-jenkins.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-jenkins"
  }
}

# --- EC2 Instance ---
resource "aws_instance" "web-jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public-jenkins.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg-jenkins.id]
  key_name                    = var.key_name
  iam_instance_profile        = "ssm-role"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = var.ec2_name
  }
}


# --- Fetch Latest Ubuntu AMI ---
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
