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

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}



# data "aws_vpc" "click_count" {
#   filter {
#     name   = "tag:Env"
#     values = [var.env]
#   }
# }

# data "aws_subnet" "click_count" {
#   filter {
#     name   = "tag:Env"
#     values = [var.env]
#   }
# }

# data "aws_subnet_ids" "click_count" {
#   vpc_id = data.aws_vpc.click_count.id
#   tags = {
#     Env = var.env
#   }
# }

# TODO: use terraform_remote_state where possible
data "aws_security_group" "sg-web-lb" {
  filter {
    name   = "tag:Env"
    values = [var.env]
  }

  filter {
    name   = "tag:Name"
    values = ["sg-allow-web-lb"]
  }
}

data "aws_security_group" "sg-eb" {
  filter {
    name   = "tag:Env"
    values = [var.env]
  }

  filter {
    name   = "tag:Name"
    values = ["sg-eb"]
  }
}
# FIXME
# data "aws_security_group" "default" {

#   filter {
#     name   = "tag:Name"
#     values = ["default"]
#   }
# }

resource "aws_security_group" "click_count_allow_redis" {
  name        = "allow_redis"
  description = "Allow Redis inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Redis from ${data.aws_security_group.sg-web-lb.name}"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    # security_groups = [data.aws_security_group.sg-web-lb.id]
    security_groups = [data.aws_security_group.sg-eb.id]
  }

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    # security_groups = [aws_default_vpc.default.id]
  }

  # ingress {
  #   description     = "Redis from VPC"
  #   from_port       = 6379
  #   to_port         = 6379
  #   protocol        = "tcp"
  #   security_groups = [data.aws_security_group.click_count.id]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-allow-redis"
    Env         = var.env
    Provisioner = "terraform"
  }
}

# resource "aws_elasticache_subnet_group" "Subnet" {
#   name = "subnet"
#   # subnet_ids = [data.aws_subnet.click_count.id]
#   subnet_ids = data.aws_subnet_ids.click_count.ids
# }

# resource "aws_elasticache_cluster" "click_count" {
#   # cluster_id           = var.project_name
#   cluster_id           = "${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}"
#   engine               = "redis"
#   node_type            = "cache.t2.micro"
#   num_cache_nodes      = 1
#   parameter_group_name = "default.redis6.x"
#   engine_version       = "6.x"
#   port                 = 6379
#   security_group_ids   = [aws_security_group.click_count_allow_redis.id]
#   # subnet_group_name    = "${aws_elasticache_subnet_group.Subnet.name}"
# }



resource "aws_elasticache_replication_group" "click_count" {
  replication_group_id          = "${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}"
  replication_group_description = "redis - click-count"
  node_type                     = "cache.t2.micro"
  port                          = 6379
  parameter_group_name          = "default.redis6.x"
  # FIXME
  security_group_ids = [aws_security_group.click_count_allow_redis.id]
  # security_group_ids = ["sg-df4c22b2", aws_security_group.click_count_allow_redis.id]
  # security_group_ids = ["sg-df4c22b2"]

  cluster_mode {
    num_node_groups         = 1
    replicas_per_node_group = 0
  }

  tags = {
    Env         = var.env
    Provisioner = "terraform"
  }
}
