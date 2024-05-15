variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
  default = "eu-central-1"
}

variable "azs" {
  type = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "vpc" {
  type = object({
    cidr_block = string
    public_subnets_cidr_blocks = list(string)
    private_subnets_cidr_blocks = list(string)
  })
}

variable "ecr" {
  type = map(object({
    name_prefix = string
  }))
}

variable "ecs" {
  type = object({
    min_cluster_size = number
    max_cluster_size = number
    desired_cluster_size = number 
  })
}
