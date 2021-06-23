terraform {
  required_version = "~> 0.13.7" // Terraform frequently puts breaking changes into minor and patch version releases. _Always_ hard pin to the latest known and tested working version. Do not trust semantic versioning.
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "random" {
  byte_length = 4
}

# This retrieves the latest AMI ID for Ubuntu 16.04.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}