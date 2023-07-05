resource "aws_internet_gateway" "jenkins_gateway" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "jenkins"
    }
  )
}
