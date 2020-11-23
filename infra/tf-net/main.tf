# Declare the aws provider
provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    bucket = "click-count-tfstate"
    key    = "net/terraform.tfstate"
    region = "eu-west-3"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# resource "aws_vpc" "click_count" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"

#   tags = {
#     Name = "vpc-${var.env}"
#     Env  = var.env
#   }
# }

# resource "aws_subnet" "click_count_subnet_a" {
#   vpc_id     = aws_vpc.click_count.id
#   cidr_block = "10.0.0.0/24"

#   tags = {
#     Name = "subnet-a-${var.env}"
#     Env  = var.env
#   }
# }

# resource "aws_subnet" "click_count_subnet_b" {
#   vpc_id     = aws_vpc.click_count.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "subnet-b-${var.env}"
#     Env  = var.env
#   }
# }



resource "aws_security_group" "allow_web_lb" {
  name        = "${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}-web-ssh-lb"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Web from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "sg-allow-web-lb"
    Env      = var.env
    Provider = "terraform"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}-web-ssh"
  description = "Allow Web and SSH inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  # ingress {
  #   description = "Web from VPC"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_default_vpc.default.cidr_block]
  # }

  ingress {
    description = "Web from lb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # cidr_blocks = [aws_default_vpc.default.cidr_block]
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.allow_web_lb.id]
  }

  ingress {
    description = "ssh from anywhere"
    from_port   = 22
    to_port     = 22
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
    Name     = "sg-eb"
    Env      = var.env
    Provider = "terraform"
  }
}
