resource "aws_key_pair" "jenkins_keypair" {
  key_name   = "jenkins_keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "jenkins"
  }
}

resource "aws_eip" "jenkins" {
  vpc = true
}

resource "aws_instance" "jenkins" {
  associate_public_ip_address = true  # Do not assign public IP

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.jenkins_keypair.key_name
  security_groups = [aws_security_group.jenkins.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
  subnet_id = aws_subnet.jenkins_vpc_main[0].id

  user_data = base64encode(
    templatefile("${path.module}/user_data.sh", { 
        example_var = "Hello, World!", 
        LB_URL = aws_lb.jenkins_alb.dns_name,
        PLUGIN_CLI_VERSION = "2.12.11",
        SSH_USERNAME = var.ssh_username,
        SSH_KEY_PASSWORD = "${var.ssh_key_password}",
        GITLAB_PRIVATE_KEY = base64encode(file("${path.module}/../${var.gitlab_private_key_path}")),
        DRNAME = aws_ecr_repository.repository.repository_url,
        AWSACCOUNTID = data.aws_caller_identity.current.account_id,
        AWSVPCID = aws_vpc.jenkins_vpc.id
    }
  ))

  tags = merge(
    local.common_tags,
    {
      Name = "jenkins"
    }
  )
}

resource "aws_eip_association" "jenkins" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins.id
}