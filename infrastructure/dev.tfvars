app_name = "cloud"
environment = "dev"
vpc = {
  cidr_block = "10.0.0.0/16"
  public_subnets_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr_blocks = ["10.0.100.0/24", "10.0.200.0/24"]
}
