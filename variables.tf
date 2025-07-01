# keys
variable "access_key" {
  type        = string
  description = "The AWS region where resources will be deployed, such as 'ap-south-1'."
}
variable "secret_key" {
  type        = string
  description = "The AWS region where resources will be deployed, such as 'ap-south-1'."
}

# region
variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed, such as 'ap-south-1'."
}
variable "availability_zone_a" {
  type        = string
  description = "The first availability zone for deploying resources, such as 'ap-south-1a'."
}
variable "availability_zone_b" {
  type        = string
  description = "The first availability zone for deploying resources, such as 'ap-south-1b'."
}

# keypair 
variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

# identity vpc and subnets cidr blocks
variable "identity_vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the identity VPC"
}
variable "identity_public_subnet_a_cidr_block" {
  type        = string
  description = "The CIDR block for the public subnet A in the identity VPC"
}
variable "identity_private_subnet_a_cidr_block" {
  type        = string
  description = "The CIDR block for the private subnet A in the identity VPC"
}

# ALB VPC and subnets cidr blocks
variable "alb_vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the ALB VPC"
}
variable "alb_public_subnet_a_cidr_block" {
  type        = string
  description = "The CIDR block for the ALB public subnet A in the ALB VPC"
}
variable "alb_public_subnet_b_cidr_block" {
  type        = string
  description = "The CIDR block for the ALB public subnet B in the ALB VPC"
}
