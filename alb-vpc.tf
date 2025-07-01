# vpc 
resource "aws_vpc" "alb-vpc" {
    cidr_block           = var.alb_vpc_cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "alb-vpc"
    }
}

# subnets
resource "aws_subnet" "alb-public-subnet-a" {
  vpc_id                  = aws_vpc.alb-vpc.id
  cidr_block              = var.alb_public_subnet_a_cidr_block
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true
  tags = {
    Name = "alb-public-subnet-a"
  }
}
resource "aws_subnet" "alb-public-subnet-b" {
  vpc_id                  = aws_vpc.alb-vpc.id
  cidr_block              = var.alb_public_subnet_b_cidr_block
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true
  tags = {
    Name = "alb-public-subnet-b"
  }
}

# IGW
resource "aws_internet_gateway" "alb-internet-gateway" {
  vpc_id = aws_vpc.alb-vpc.id
  tags = {
    Name = "alb-internet-gateway"
  }
}

# attach IGW to default route table
resource "aws_default_route_table" "alb-public-rt" {
  default_route_table_id = aws_vpc.alb-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alb-internet-gateway.id
  }
   route {
    cidr_block = var.identity_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }
  tags = {
    Name = "alb-public-rt"
  }
}


# associtaion for public subnets in rt
resource "aws_route_table_association" "alb-rt-association" {
  subnet_id      = aws_subnet.alb-public-subnet-a.id
  route_table_id = aws_default_route_table.alb-public-rt.id
}

resource "aws_route_table_association" "alb-rt-association2" {
  subnet_id      = aws_subnet.alb-public-subnet-b.id
  route_table_id = aws_default_route_table.alb-public-rt.id
}

# security group creation
resource "aws_security_group" "alb_sg" {
  name          = "alb-sg"
  description   = "This sg allows a traffic for the server"
  vpc_id        = aws_vpc.alb-vpc.id
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "alb-sg" 
  } 
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.alb-vpc.id
  peer_vpc_id = aws_vpc.identity-vpc.id
  auto_accept = true

  tags = {
    Name = "VPC Peering between ALB and Identity VPCs"
  }
}

# ALB 
resource "aws_lb" "alb_lb" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.alb-public-subnet-a.id, aws_subnet.alb-public-subnet-b.id]
}

# target group
resource "aws_lb_target_group" "lb_tg" {
  name                  = "test-alb-tg"
  port                  = 80
  protocol              = "HTTP"
  vpc_id                = aws_vpc.alb-vpc.id
  target_type           = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30    
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"  # Accept any 2xx or 3xx status code

  }
}

# target group attachment
resource "aws_lb_target_group_attachment" "public_target_attachment" {
  target_group_arn   = aws_lb_target_group.lb_tg.arn
  target_id          = aws_instance.identity-public-prd-server.private_ip
  port               = 80
  availability_zone  = "all"
}

resource "aws_lb_target_group_attachment" "private_target_attachment" {
  target_group_arn   = aws_lb_target_group.lb_tg.arn
  target_id          = aws_instance.identity-private-prd-server.private_ip
  port               = 80
  availability_zone  = "all"
}

# listener
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }

}
