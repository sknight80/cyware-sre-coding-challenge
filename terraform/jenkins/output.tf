output "jenkins_public_ip" {
  description = "The public IP of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "ecr_repository_url" {
  description = "The url of the ECR repository"
  value       = aws_ecr_repository.repository.repository_url
}

output "jenkins_lb_dns_name" {
  value = aws_lb.jenkins_alb.dns_name
}
