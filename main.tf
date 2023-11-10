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
  access_key = "AKIAZKLAEXHKCJF3LT7J"
  secret_key = "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"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

