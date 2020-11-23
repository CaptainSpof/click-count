variable "environment_name" {
  type        = map
  description = "Name of the project."
  default = {
    staging    = "staging"
    production = "production"
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "click-count"
}

variable "stack" {
  type    = string
  default = "beanstalk"
}

variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "env" {
  description = "env: staging or production"
}

# Beanstalk

variable "beanstalk_solution_stack_name" {
  type    = string
  default = "64bit Amazon Linux 2 v3.2.1 running Docker"
}

variable "asg_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 1
}

variable "asg_availability_zones" {
  type    = string
  default = "Any"
}
