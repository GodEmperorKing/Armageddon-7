### Security Group: ALB (Converted for CloudFront)
### Explanation: The ALB SG is the blast shield — mutated to ONLY allow CloudFront IPs!
resource "aws_security_group" "palpaking_alb_sg01" {
  name        = "${local.name_prefix}-alb-sg01"
  description = "ALB security group - strictly CloudFront only"
  vpc_id      = aws_subnet.palpaking_public_subnets[0].vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg01"
  }
}

### Explanation: palpaking only opens the hangar door — allow ALB -> EC2 on app port 80.
resource "aws_security_group_rule" "palpaking_ec2_ingress_from_alb01" {
  type                     = "ingress"
  security_group_id        = aws_security_group.palpaking_ec2_sg01.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.palpaking_alb_sg01.id
}

### Application Load Balancer

resource "aws_lb" "palpaking_alb01" {
  name               = "${local.name_prefix}-alb01"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.palpaking_alb_sg01.id]
  subnets            = aws_subnet.palpaking_public_subnets[*].id

  tags = {
    Name = "${local.name_prefix}-alb01"
  }
}

### Target Group + Attachment

resource "aws_lb_target_group" "palpaking_tg01" {
  name     = "${local.name_prefix}-tg01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_subnet.palpaking_public_subnets[0].vpc_id

  health_check {
    enabled             = true
    interval            = 10
    path                = "/list" # Pointed perfectly to your Python app!
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    matcher             = "200-399"
  }

  tags = {
    Name = "${local.name_prefix}-tg01"
  }
}

resource "aws_lb_target_group_attachment" "palpaking_tg_attach01" {
  target_group_arn = aws_lb_target_group.palpaking_tg01.arn
  port             = 80

  target_id = aws_instance.palpaking_ec201.id
}

### ALB Listener (The Chewbacca Lock)

### Explanation: The listener acts as the bouncer. It drops traffic UNLESS it has the secret header.
resource "aws_lb_listener" "palpaking_http_listener01" {
  load_balancer_arn = aws_lb.palpaking_alb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "403 Forbidden - Direct Access Blocked"
      status_code  = "403"
    }
  }
}