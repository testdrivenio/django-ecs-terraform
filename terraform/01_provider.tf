provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Name     = local.name
      Environment  = local.environment
    }
  }
}

data "aws_caller_identity" "current" {}