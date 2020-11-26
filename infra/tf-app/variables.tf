variable "stack" {
  type    = string
  default = "beanstalk"
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
