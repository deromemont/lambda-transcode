terraform {
  cloud {
    organization = "deromemont"
    hostname = "app.terraform.io"

    workspaces {
      tags = ["app:lambda-transcode"]
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

