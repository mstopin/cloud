output "node_ami" {
  value = data.aws_ssm_parameter.node_ami.value
}

output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "node_instance_profile_name" {
  value = aws_iam_instance_profile.node.name
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.main.name
}

