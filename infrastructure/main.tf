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

module "ecr" {
  source = "./modules/ecr"

  for_each = var.ecr

  name_prefix = "${local.name_prefix}-${each.value.name_prefix}"
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix = local.name_prefix

  asg_arn = module.asg.arn
}

module "asg" {
  source = "./modules/asg"

  name_prefix = "${local.name_prefix}-ecs"

  min_size = var.ecs.min_cluster_size
  max_size = var.ecs.max_cluster_size
  desired_capacity = var.ecs.desired_cluster_size
  
  ami = module.ecs.node_ami
  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${module.ecs.cluster_id} >> /etc/ecs/ecs.config;
    EOF
  )

  vpc_id = module.vpc.id
  subnets_ids = module.vpc.public_subnets_ids
  security_groups_ids = [module.vpc.allow_all_egress_sg_id, module.vpc.allow_all_internal_sg_id]

  iam_instance_profiles_names = [module.ecs.node_instance_profile_name]

  asg_tags = {
    "AmazonECSManaged" = ""
  }
}

module "alb" {
  source = "./modules/alb"

  name_prefix = "${local.name_prefix}-ecs"

  vpc_id = module.vpc.id
  subnets_ids = module.vpc.public_subnets_ids
  security_groups_ids = [module.vpc.allow_http_https_ingress_sg_id, module.vpc.allow_all_internal_sg_id]
}

module "ecs-service" {
  source = "./modules/ecs-service"

  for_each = var.ecs_services

  region = var.region
  name_prefix = local.name_prefix
  name = each.key
  
  cluster_id = module.ecs.cluster_id
  capacity_provider_name = module.ecs.capacity_provider_name
  alb_target_group_arn = module.alb.target_group_id
  desired_count = each.value.desired_count

  container_definitions = [
    for container_definition in each.value.container_definitions: {
      name = container_definition.name
      image = module.ecr[container_definition.ecr_key].url
      essential = container_definition.essential
      published_ports = container_definition.published_ports
      environment = container_definition.environment
    }
  ]
}
