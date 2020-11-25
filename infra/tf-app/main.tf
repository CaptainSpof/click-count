# Declare the aws provider
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "click-count-tfstate"
    key    = "app/terraform.tfstate"
    region = "eu-west-3"
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

data "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "beanstalk-ec2-user"
}

data "terraform_remote_state" "elasticache" {
  backend = "s3"
  config = {
    region = var.aws_region
    # TODO: export to var
    bucket = "click-count-tfstate"
    key    = "env:/${var.env}/db/terraform.tfstate"
  }
}


# data "aws_vpc" "click_count" {
#   filter {
#     name   = "tag:Env"
#     values = [var.env]
#   }
# }

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "default" {
  vpc_id = aws_default_vpc.default.id
}

# data "aws_subnet_ids" "click_count" {
#   vpc_id = data.aws_vpc.click_count.id
#   tags = {
#     Env = var.env
#   }
# }


##
## Beanstalk
##

resource "aws_elastic_beanstalk_application" "click_count" {
  name        = "${local.name}-app"
  description = ""
  tags        = local.tags
}

resource "aws_elastic_beanstalk_environment" "click_count" {
  name                   = "${local.name}-env"
  application            = aws_elastic_beanstalk_application.click_count.name
  solution_stack_name    = var.beanstalk_solution_stack_name
  tags                   = local.tags
  wait_for_ready_timeout = "20m"

  ##
  ## Environment
  ##

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_HOST"
    value     = data.terraform_remote_state.elasticache.outputs.primary_endpoint_address
  }

  ##
  ## Load Balancer
  ##

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = data.aws_security_group.sg-allow-web-lb.id
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = data.aws_security_group.sg-allow-web-lb.id
  }


  ### Listener rule

  ### Listener

  ##
  ## VPC
  ##

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_default_vpc.default.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnet_ids.default.ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", data.aws_subnet_ids.default.ids)
  }

  ##
  ## Autoscaling
  ##

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.asg_instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = data.aws_iam_instance_profile.beanstalk_ec2.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = data.aws_security_group.sg-allow-web-ssh-eb.id
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = var.asg_availability_zones
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.asg_min_size
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.asg_max_size
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = "true"
  }

}
