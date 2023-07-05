terraform {
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