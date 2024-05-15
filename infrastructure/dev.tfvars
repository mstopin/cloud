app_name = "cloud"
environment = "dev"

vpc = {
  cidr_block = "10.0.0.0/16"
  public_subnets_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr_blocks = ["10.0.100.0/24", "10.0.200.0/24"]
}

ecr = {
  "hello-world" = {
    name_prefix = "hello-world"
  }
}

ecs = {
  min_cluster_size = 2
  desired_cluster_size = 2
  max_cluster_size = 2
}

ecs_services = {
  "hello-world" = {
    desired_count = 3

    container_definitions = [{
      name = "app"
      ecr_key = "hello-world"
      essential = true
      published_ports = [8080]
      environment = [{
        name = "APP_PORT"
        value = "8080"
      }]
    }]
    
  }
}