variable "instance_type" {
  description = "The instance type to use for the Jenkins server"
#   default     = "t2.micro"
  default     = "t3.small"
}

variable "ami" {
  description = "The AMI to use for the Jenkins server"
  default     = "ami-053b0d53c279acc90" // This is an Amazon Linux 2 AMI, check the latest AMI ID in your region
}

variable "ssh_username" {
  default = "sknight80"
  description = "this used in git repo interaction"
}

variable "ssh_key_password" {
  default = ""
  description = "key password for ssh if any"
}

variable "gitlab_private_key_path" {
  default = "../jenkins_example"
  description = "path to gitlab private key"
}