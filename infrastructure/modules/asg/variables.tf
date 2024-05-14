variable "name_prefix" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_capacity" {
  type = number
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

variable "ami" {
  type = string
}

variable "tags" {
  type = map(string)
}
