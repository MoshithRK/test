# vpc
resource "aws_vpc" "identity-vpc" {
  cidr_block           = var.identity_vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
      Name = "identity-vpc"
  }
}

# subnet
resource "aws_subnet" "identity-public-subnet-a" {
  vpc_id                  = aws_vpc.identity-vpc.id
  cidr_block              = var.identity_public_subnet_a_cidr_block
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true
  tags = {
    Name = "identity-public-subnet-a"
  }
}

resource "aws_subnet" "identity-private-subnet-a" {
  vpc_id = aws_vpc.identity-vpc.id
  cidr_block = var.identity_private_subnet_a_cidr_block
  availability_zone = var.availability_zone_a
    tags = {
    Name = "identity-private-subnet-a"
  }
}
# IGW
resource "aws_internet_gateway" "identity-internet-gateway" {
  vpc_id = aws_vpc.identity-vpc.id
  tags   = {
    Name = "identity-internet-gateway"
  }
}

# attach IGW to default route table
resource "aws_default_route_table" "identity-public-rt" {
  default_route_table_id = aws_vpc.identity-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.identity-internet-gateway.id
  }
  route {
    cidr_block = var.alb_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }
  tags = {
    Name = "identity-public-rt"
  }

}

# associtaion for public subnets in public rt
resource "aws_route_table_association" "identity-public-rt-association" {
  subnet_id      = aws_subnet.identity-public-subnet-a.id
  route_table_id = aws_default_route_table.identity-public-rt.id
} 

# private route table creation
resource "aws_route_table" "identity-private-rt" {
  vpc_id = aws_vpc.identity-vpc.id
   route {
    cidr_block = var.alb_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }
  tags = {
  Name = "identity-private-rt"
}
}

# associtaion for private subnets in private rt
resource "aws_route_table_association" "identity-private-rt-association" {
  subnet_id      = aws_subnet.identity-private-subnet-a.id
  route_table_id = aws_route_table.identity-private-rt.id
}

# security group
resource "aws_security_group" "identity-sg" {
  name          = "identity-sg"
  description   = "This sg allows a traffic for the server"
  vpc_id        = aws_vpc.identity-vpc.id
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  # ingress {
  #   description     = "Allow HTTP from ALB"
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.alb_sg.id]
  # }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "identity-sg" 
  } 
}



# EC2
resource "aws_instance" "identity-public-prd-server" {
  ami                         = "ami-021a584b49225376d" 
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.identity-public-subnet-a.id
  vpc_security_group_ids      = [aws_security_group.identity-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "identity-public-prd-server"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "<h1 style='color: blue;'>PUBLIC Instance: $(hostname -f)</h1>" > /var/www/html/index.html
              echo "<p>This instance is in a public subnet</p>" >> /var/www/html/index.html
              EOF

}

resource "aws_instance" "identity-private-prd-server" {
  ami                         = "ami-021a584b49225376d" 
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.identity-private-subnet-a.id
  vpc_security_group_ids      = [aws_security_group.identity-sg.id]

  tags = {
    Name = "identity-private-prd-server"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "<h1 style='color: green;'>PRIVATE Instance: $(hostname -f)</h1>" > /var/www/html/index.html
              echo "<p>This instance is in a private subnet</p>" >> /var/www/html/index.html
              EOF
}



# terraform destroy -auto-approve -var-file=terraform-prd.tfvars

# terraform plan -var-file=terraform-prd.tfvars
# terraform apply -auto-approve -var-file=terraform-prd.tfvars