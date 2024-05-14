resource "aws_autoscaling_group" "this" {
  name = "${var.name_prefix}-asg" 
  
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = var.subnets_ids

  health_check_type = "EC2"
  health_check_grace_period = 30

  wait_for_capacity_timeout = "2m"

  launch_template {
    id = aws_launch_template.main.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "main" {
  name = "${var.name_prefix}-lt"

  instance_type = "t2.micro"
  image_id = var.ami

  vpc_security_group_ids = var.security_groups_ids

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      "Name" = "${var.name_prefix}-asg-node"
    }, var.tags)
  }
}
