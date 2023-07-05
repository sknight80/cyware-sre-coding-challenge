# locals {
#   aws_account_name = "test"
# }

terraform {
  backend "s3" {
    bucket         = "cyware-terraform-state-test"
    dynamodb_table = "terraform-state-lock"
    key            = "cyware-jenkins.tfstate"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 5.0"
    }
  }
  required_version = "< 2.0"
}

provider "aws" {
  region = "us-east-1"
}
