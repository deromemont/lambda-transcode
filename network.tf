resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "lambda-transcode"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "lambda-transcode"
  }
}

data "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_vpc.main.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}