############
#ALB
############
resource "aws_lb" "alb" {
  name               = "${var.env}-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = var.public_subnets
  security_groups = [var.alb_sg_id]

  tags = {
    Name = "${var.env}-alb"
  }
}

############
#TG
############
resource "aws_lb_target_group" "tg" {
  name        = "${var.env}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.env}-tg"
  }
}

############
#Listener
############
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      status_code  = "403"
      content_type = "text/plain"
      message_body = "Forbidden"
    }
  }
}

resource "aws_lb_listener_rule" "allow_cloudfront_only" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    http_header {
      http_header_name = "X-Origin-Verify"
      values           = ["my-secret-12345"]
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn

  port     = 443
  protocol = "HTTPS"

  certificate_arn = var.alb_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "https_cloudfront_only" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  condition {
    http_header {
      http_header_name = "X-Origin-Verify"
      values           = ["my-secret-12345"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}