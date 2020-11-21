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

resource "aws_vpc" "click_count" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}"
    Env  = var.env
  }
}

resource "aws_subnet" "click_count" {
  vpc_id     = aws_vpc.click_count.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "subnet-${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}"
    Env  = var.env
  }
}

resource "aws_security_group" "allow_web" {
  name        = "${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}-web-ssh"
  description = "Allow Web and SSH inbound traffic"
  vpc_id      = aws_vpc.click_count.id

  ingress {
    description = "Web from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.click_count.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
    Env  = var.env
  }
}
