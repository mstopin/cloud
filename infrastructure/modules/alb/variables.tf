variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets_ids" {
  type = list(string)
}

variable "security_groups_ids" {
  type = list(string)
}
