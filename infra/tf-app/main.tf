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

# Create a random id
resource "random_id" "tf_bucket_id" {
  byte_length = 2
}

# Create the bucket
resource "aws_s3_bucket" "tf_code" {
  bucket = "${lookup(var.project_name, var.env)}-${random_id.tf_bucket_id.dec}"
  acl    = "private"

  force_destroy = true

  tags = {
    Name = "tf_bucket"
  }
}
