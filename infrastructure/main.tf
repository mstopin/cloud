terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  name_prefix = "${var.app_name}-${var.environment}"
}


module "vpc" {
  source = "./modules/vpc"

  name_prefix = local.name_prefix

  azs = var.azs
  cidr_block = var.vpc.cidr_block
  public_subnets_cidr_blocks = var.vpc.public_subnets_cidr_blocks
  private_subnets_cidr_blocks = var.vpc.private_subnets_cidr_blocks
}