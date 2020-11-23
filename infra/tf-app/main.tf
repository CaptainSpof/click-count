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

# data "aws_elasticache_cluster" "click_count" {
#   tags = {
#     Env = var.env
#   }
# }

# data "terraform_remote_state" "elasticache" {
#   backend = "remote"

#   config = {
#     organization = "hashicorp"
#     workspaces = {
#       name = "vpc-prod"
#     }
#   }
# }

data "terraform_remote_state" "elasticache" {
  backend = "s3"
  config = {
    region = var.aws_region
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

# data "aws_subnet_ids" "click_count" {
#   vpc_id = data.aws_vpc.click_count.id
#   tags = {
#     Env = var.env
#   }
# }

data "aws_subnet_ids" "default" {
  vpc_id = aws_default_vpc.default.id
}

##
## IAM - Role / Policy
##

resource "aws_iam_role" "beanstalk_ec2" {
  # name               = "beanstalk-ec2-role"
  name               = "beanstalk-ec2-user"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Env         = var.env
    Project     = var.project_name
    Provisioner = "terraform"
  }
}

resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "beanstalk-ec2-user"
  role = aws_iam_role.beanstalk_ec2.name
}

resource "aws_iam_role" "beanstalk_service" {
  name               = "beanstalk-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
  # tags               = local.tags

  tags = {
    Env         = var.env
    Project     = var.project_name
    Provisioner = "terraform"
  }
}

resource "aws_iam_policy_attachment" "beanstalk_service" {
  name       = "elastic-beanstalk-service"
  roles      = [aws_iam_role.beanstalk_service.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "beanstalk_service_health" {
  name       = "elastic-beanstalk-service-health"
  roles      = [aws_iam_role.beanstalk_service.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_worker" {
  name       = "elastic-beanstalk-ec2-worker"
  roles      = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_docker" {
  name       = "elastic-beanstalk-ec2-docker"
  roles      = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

##
## Beanstalk
##

resource "aws_elastic_beanstalk_application" "click_count" {
  name        = "${var.project_name}-${var.stack}-${var.env}-app"
  description = ""
  # tags        = local.tags

  tags = {
    Env         = var.env
    Project     = var.project_name
    Provisioner = "terraform"
  }
}

resource "aws_elastic_beanstalk_environment" "click_count" {
  name                = "${var.project_name}-${var.stack}-${var.env}-env"
  application         = aws_elastic_beanstalk_application.click_count.name
  solution_stack_name = var.beanstalk_solution_stack_name
  # tags                   = local.tags
  wait_for_ready_timeout = "20m"

  ##
  ## Environment
  ##

  # setting {
  #   namespace = "aws:elasticbeanstalk:environment"
  #   name      = "LoadBalancerIsShared"
  #   value     = "true"
  # }

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
    value     = data.aws_security_group.sg-web-lb.id
    # value     = data.aws_security_group.click_count-web-ssh.id
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = data.aws_security_group.sg-web-lb.id
    # value     = data.aws_security_group.click_count-web-ssh.id
  }


  # setting {
  #   namespace = "aws:elbv2:loadbalancer"
  #   name      = "SharedLoadBalancer"
  #   value     = data.terraform_remote_state.alb.outputs.alb_arn
  # }

  ### Listener rule

  ### Listener

  ##
  ## VPC
  ##

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_default_vpc.default.id
    # value     = data.aws_vpc.click_count.id
  }

  # setting {
  #   namespace = "aws:ec2:vpc"
  #   name      = "ELBScheme"
  #   value     = "Internal"
  # }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnet_ids.default.ids)
    # value     = join(",", data.aws_subnet_ids.click_count.ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", data.aws_subnet_ids.default.ids)
    # value     = join(",", data.aws_subnet_ids.click_count.ids)
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
    value     = aws_iam_instance_profile.beanstalk_ec2.name
  }

  # setting {
  #   namespace = "aws:autoscaling:launchconfiguration"
  #   name      = "SSHSourceRestriction"
  #   value     = "tcp,22,22,0.0.0.0/0"
  # }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${data.aws_security_group.sg-eb.id}"
    # value = "${aws_default_security_group.default.id}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = var.asg_availability_zones
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.asg_min_size
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.asg_max_size
    resource  = ""
  }

  tags = {
    Env         = var.env
    Project     = var.project_name
    Provisioner = "terraform"
  }

}

# resource "aws_default_security_group" "default" {
#   vpc_id = aws_default_vpc.default.id

#   ingress {
#     description     = "Redis from ${data.aws_security_group.sg-eb.name}"
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [data.aws_security_group.sg-eb.id]
#   }
# }
