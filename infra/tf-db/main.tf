# Declare the aws provider
provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    bucket = "click-count-tfstate"
    key    = "db/terraform.tfstate"
    region = "eu-west-3"
  }
}

data "aws_vpc" "click_count" {
  filter {
    name   = "tag:Env"
    values = [var.env]
  }
}

data "aws_subnet" "click_count" {
  filter {
    name   = "tag:Env"
    values = [var.env]
  }
}

data "aws_security_group" "click_count" {
  filter {
    name   = "tag:Env"
    values = [var.env]
  }
}

resource "aws_security_group" "click_count_allow_redis" {
  name        = "allow_redis"
  description = "Allow Redis inbound traffic"
  vpc_id      = data.aws_vpc.click_count.id

  ingress {
    description     = "Redis from VPC"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [data.aws_security_group.click_count.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_redis"
    Env  = "var.env"
  }
}

resource "aws_elasticache_cluster" "click_count" {
  # cluster_id           = var.project_name
  cluster_id           = "${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"
  port                 = 6379
  security_group_ids   = [aws_security_group.click_count_allow_redis.id]
  subnet_group_name    = "${aws_elasticache_subnet_group.Subnet.name}"
}

resource "aws_elasticache_subnet_group" "Subnet" {
  name       = "subnet"
  subnet_ids = [data.aws_subnet.click_count.id]
}
