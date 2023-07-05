resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins.id]
  subnets            = aws_subnet.jenkins_vpc_main[*].id

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      "app" = "Jenkins",
    },
  )
}

resource "aws_lb_listener" "cyware_listener_80" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cyware_jenkins_target_80.arn
  }
}

# resource "aws_lb_listener" "cyware_listener_443" {
#   load_balancer_arn = aws_lb.jenkins.arn
#   port              = "443"
#   protocol          = "HTTPS"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.cyware_jenkins_target_443.arn
#   }
# }


resource "aws_lb_target_group" "cyware_jenkins_target_80" {
  name     = "cyware-jenkins-target"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = resource.aws_vpc.jenkins_vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    path                = "/"
    port                = "8080"
  }

  depends_on = [
    aws_lb.jenkins_alb
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# attach the target group to the ALB
resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.cyware_jenkins_target_80.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}



# resource "aws_lb_target_group" "cyware_jenkins_target_443" {
#   name     = "cyware-jenkins-target-443"
#   port     = 443
#   protocol = "HTTPS"
#   vpc_id   = resource.aws_vpc.main.id
#   stickiness {
#     type = "source_ip"
#   }

#   depends_on = [
#     aws_lb.jenkins
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }
# }
