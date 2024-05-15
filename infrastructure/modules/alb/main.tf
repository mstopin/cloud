resource "aws_lb" "this" {
  name = "${var.name_prefix}-alb"

  internal = false
  load_balancer_type = "application"
  subnets = var.subnets_ids
  security_groups = var.security_groups_ids
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.this.arn

  protocol = "HTTP"
  port = 80

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group" "main" {
  name = "${var.name_prefix}-alb-tg"

  target_type = "instance"
  protocol = "HTTP"
  port = 80
  
  vpc_id = var.vpc_id

  health_check {
    path = "/health"
    matcher = "200"
  }
}
