output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.web-jenkins.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.web-jenkins.public_dns
}
