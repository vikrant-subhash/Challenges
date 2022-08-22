#Security Groups For Application Load balancer
#Incoming traffic is from Port 80 which uses http Protocol

resource "aws_security_group" "load_balancer" {
  name        = "${var.env_code}-load-balancer"
  description = "Allow port 80 TCP inbound to ELB"
  vpc_id      = var.vpc_id

  ingress {
    description = "http to ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-load-balancer"
  }
}

# Load balancer and attached Security group 
#LB created accross all Public Subnets id's from the output variable of VPC modules
resource "aws_lb" "main" {
  name               = var.env_code
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = var.env_code
  }
}

# aws loadbalancer is created which will be reffered in autoscaling groups.
# Health check is placed on Loadbalancer
resource "aws_lb_target_group" "main" {
  name     = var.env_code
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200

  }
}

#aws loadbalancer Listener which listens on port 80 and forwards traffic to Loadbalancer target groups
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
