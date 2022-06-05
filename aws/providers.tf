terraform {
  required_version = ">=0.13.1"
  required_providers {
    aws = ">= 3.54.0"
    local = ">= 2.1.0"
  }
  backend "s3" {
    bucket = "programadev-bucket"
    key = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}