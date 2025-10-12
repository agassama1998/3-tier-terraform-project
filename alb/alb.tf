#created a security group to allow inbound HTTPS traffic from the VPC CIDR block and allow all outbound traffic to any destination
resource "aws_security_group" "apci_jupiter_alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http_traffic"
  }
}

#ingress/inbound rule to allow inbound HTTP traffic from the VPC CIDR block
resource "aws_vpc_security_group_ingress_rule" "alb_allow_http" {
  security_group_id = aws_security_group.apci_jupiter_alb_sg.id #reference the security group created above
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#ingress/inbound rule to allow inbound HTTPS traffic from the VPC CIDR block
resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  security_group_id = aws_security_group.apci_jupiter_alb_sg.id #reference the security group created above
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_alb_sg.id #reference the security group created above
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#CRATING TARGET GROUP FOR ALB TO POINT TO EC2 INSTANCES --------------------------------------------------------------
resource "aws_lb_target_group" "apci_jupiter_tg" {
  name        = "apci-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

    health_check {
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200,301,302"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}


#CREATING APPLICATION LOAD BALANCER -------------------------------------------------------------------------
resource "aws_lb" "apci_jupiter_alb" {
  name               = "apci-jupiter-alb"
  internal           = false
  load_balancer_type = "application" # this specify whether its for application or network
  security_groups    = [aws_security_group.apci_jupiter_alb_sg.id] # reference the security group created above
  subnets            = [var.apci_jupiter_public_subnet_az_1a, var.apci_jupiter_public_subnet_az_1c] # reference the public subnets created in VPC module, using variable.tf file in alb module.

  enable_deletion_protection = false   # we can enable this to prevent accidental deletion of the ALB



    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb"
  })
}

#CREATING LISTENER FOR THE ALB TO LISTEN TO INBOUND HTTP TRAFFIC ------------------------------------------------
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.apci_jupiter_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {     # this block is used to define what action the listener should take when it receives a request.
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#CREATING HTTPS LISTENER FOR THE ALB TO LISTEN TO INBOUND HTTPS TRAFFIC ------------------------------------------------
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.apci_jupiter_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy       = var.ssl_policy # this is the SSL policy to be used by the ALB
  certificate_arn  = var.certificate_arn # this is the ARN of the SSL certificate to be used by the ALB, we will create this in ACM module

  default_action {     # this block is used to define what action the listener should take when it receives a request.
    type             = "forward" # this specifies that the listener should forward the request to the target group specified below
    target_group_arn = aws_lb_target_group.apci_jupiter_tg.arn
  }
}
