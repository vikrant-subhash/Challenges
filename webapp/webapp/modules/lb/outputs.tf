output target_group_arn {
  value = aws_lb_target_group.main.id
}

output load_balancer_sg {
  value = aws_security_group.load_balancer.id
}
