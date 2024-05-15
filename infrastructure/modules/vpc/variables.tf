variable "name_prefix" {
  type = string
}

variable "azs" {
  type = list(string)
  description = "Availability zones"
}

variable "cidr_block" {
  type = string
}

variable "public_subnets_cidr_blocks" {
  type = list(string)
}

variable "private_subnets_cidr_blocks" {
  type = list(string)
}
