terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket               = "aws-s3-state-file-storage"
    key                  = "terraform-state"
    region               = "us-east-1"
    encrypt              = true
    workspace_key_prefix = "cloudpulse-demo"
    use_lockfile         = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}
