locals {
  deletion_protection = false
  common_tags = {
    Project     = "cyware-jenkins-pipeline",
    Contact     = "knight.secret@gmail.com",
    Team        = "SRE/DevOps",
    Group       = "DevOps",
    Environment = "development",
  }

  hosted_zone_name = "jenkins.dev.cyware.io"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}