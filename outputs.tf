output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb_lb.dns_name
}

output "public_instance_ip" {
  description = "Public IP of the public instance"
  value       = aws_instance.identity-public-prd-server.public_ip
}

output "public__instance_private_ip" {
  description = "Public IP of the public instance"
  value       = aws_instance.identity-public-prd-server.private_ip
}

output "private_instance_ip" {
  description = "Private IP of the private instance"
  value       = aws_instance.identity-private-prd-server.private_ip
}