terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = "ap-southeast-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "vscode"
}

terraform {
  backend "s3" {
    bucket = "patrick-state-bucket"
    key    = "global/state/terraform.tfstate"
    region = "ap-southeast-1"
  }
}