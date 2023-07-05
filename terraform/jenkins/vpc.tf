resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "jenkins"
    }
  )
}

resource "aws_subnet" "jenkins_vpc_main" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  count             = 2
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}
