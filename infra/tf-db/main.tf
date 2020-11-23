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
data "aws_security_group" "sg-allow-web-lb" {
  filter {
    name   = "tag:Env"
    values = ["shared"]
  }

  filter {
    name   = "tag:Name"
    values = ["sg-allow-web-lb"]
  }
}

data "aws_security_group" "sg-allow-web-ssh-eb" {
  filter {
    name   = "tag:Env"
    values = ["shared"]
  }

  filter {
    name   = "tag:Name"
    values = ["sg-allow-web-ssh-eb"]
  }
}


data "aws_security_group" "sg-allow-redis" {
  filter {
    name   = "tag:Env"
    values = ["shared"]
  }

  filter {
    name   = "tag:Name"
    values = ["sg-allow-redis"]
  }
}

# FIXME
# data "aws_security_group" "default" {

#   filter {
#     name   = "tag:Name"
#     values = ["default"]
#   }
# }


resource "aws_elasticache_replication_group" "click_count" {
  replication_group_id          = "${var.project_name}-${var.stack}-${lookup(var.environment_name, var.env)}"
  replication_group_description = "redis - click-count"
  node_type                     = "cache.t2.micro"
  port                          = 6379
  parameter_group_name          = "default.redis6.x"
  security_group_ids            = [data.aws_security_group.sg-allow-redis.id]

  cluster_mode {
    num_node_groups         = 1
    replicas_per_node_group = 0
  }

  tags = {
    Env         = var.env
    Provisioner = "terraform"
    Project     = var.project_name
  }
}
