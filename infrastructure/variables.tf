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
