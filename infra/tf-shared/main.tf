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

resource "aws_security_group" "sg-allow-web-lb" {
  name        = "${local.short_name}-web-lb"
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

  tags = merge(
    local.tags,
    {
      Name = "sg-allow-web-lb"
    },
  )
}

resource "aws_security_group" "sg-allow-web-ssh-eb" {
  name        = "${local.short_name}-web-ssh-eb"
  description = "Allow Web and SSH inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description     = "Web from lb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-allow-web-lb.id]
  }

  ingress {
    description = "SSH from anywhere"
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

  tags = merge(
    local.tags,
    {
      Name = "sg-allow-web-ssh-eb"
    },
  )
}

resource "aws_security_group" "sg-allow-redis" {
  name = "${local.short_name}-allow-redis"
  # name = "${local.name}-allow-redis"
  # name        = "allow_redis"
  description = "Allow Redis inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description     = "Redis from ${aws_security_group.sg-allow-web-lb.name}"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-allow-web-ssh-eb.id]
  }

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(
    local.tags,
    {
      Name = "sg-allow-redis"
    },
  )
}


##
## IAM - Role / Policy
##

resource "aws_iam_role" "beanstalk_ec2" {
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
  tags               = local.tags
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
  tags               = local.tags

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
