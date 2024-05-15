variable "region" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "name" {
 type = string 
}

variable "cluster_id" {
  type = string
}

variable "desired_count" {
 type = number 
}

variable "cpu" {
  type = number
  default = 128
}

variable "memory" {
  type = number
  default = 128
}

variable "container_definitions" {
  type = list(object({
    name = string
    image = string
    essential = bool
    published_ports = list(number)
    environment = list(object({
      name = string
      value = string
    }))
  }))
  default = []
}

variable "capacity_provider_name" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}