data "aws_ssm_parameter" "node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "aws_iam_policy_document" "node" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"
}

resource "aws_iam_role" "node" {
  name = "${var.name_prefix}-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.node.json
}

resource "aws_iam_role_policy_attachment" "node" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "node" {
  name_prefix = "${var.name_prefix}-ecs-node-instance-profile"
  role = aws_iam_role.node.name
}

resource "aws_ecs_capacity_provider" "main" {
  name = "${var.name_prefix}-ecs-capacity-provider"
  
  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]
  
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
  }
}
