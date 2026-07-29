resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-vpc"
  }
}
provider "aws" {
  region = "ap-south-1"
}
resource "aws_internet_gateway" "tf-gw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "tf-gw"
  }
}

resource "aws_subnet" "tf-public-subnet-1" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tf-public-subnet-1"
  }
}

resource "aws_subnet" "tf-private-subnet-1" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "tf-private-subnet-1"
  }
}

resource "aws_route_table" "tf-public-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-gw.id
  }

  tags = {
    Name = "tf-public-rt"
  }
}

resource "aws_route_table" "tf-private-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-nat-gw.id
  }
  tags = {
    Name = "tf-private-rt"
  }
}

resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.tf-public-subnet-1.id
  route_table_id = aws_route_table.tf-public-rt.id
}

resource "aws_route_table_association" "private-rt-association" {
  subnet_id      = aws_subnet.tf-private-subnet-1.id
  route_table_id = aws_route_table.tf-private-rt.id

}

resource "aws_eip" "tf-nat-gw" {

  domain = "vpc"
  tags = {
    Name = "tf-nat-gw"
  }
}

resource "aws_nat_gateway" "tf-nat-gw" {
  allocation_id = aws_eip.tf-nat-gw.id
  subnet_id     = aws_subnet.tf-public-subnet-1.id

  tags = {
    Name = "tf-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # depends_on = [aws_internet_gateway.tf-gw]
}

# --------------Security Group for TLS Inbound Traffic and All Outbound Traffic --------------
resource "aws_security_group" "allow_port_80" {
  name        = "allow_port_80"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  tags = {
    Name = "allow_port_80"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_port_80.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_port_80.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_port_80.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_instance" "tf-instance" {
  ami                         = "ami-0e38835daf6b8a2b9"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.tf-public-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.allow_port_80.id]
  associate_public_ip_address = true

  tags = {
    Name = "tf-example"
  }
}

# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.tf-instance.id
#   allocation_id = aws_eip.tf-nat-gw.id
# }

