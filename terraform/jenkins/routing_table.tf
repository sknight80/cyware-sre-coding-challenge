resource "aws_route_table" "jenkins_route_table" {
  vpc_id = aws_vpc.jenkins_vpc.id

  // Remove the route that directs traffic to the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_gateway.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "jenkins"
    }
  )
}

resource "aws_main_route_table_association" "jenkins_route_table_association" {
  vpc_id         = aws_vpc.jenkins_vpc.id
  route_table_id = aws_route_table.jenkins_route_table.id
}