
resource "aws_security_group" "apci_jupiter_app_sg" {
  name        = "jupiter-app-sg"
  description = "Allow SSH and HTTP(s) traffic from alb"
  vpc_id      = var.vpc_id  # Reference the VPC ID variable

  tags = {
    Name = "allow-ssh-http-traffic"
  }
}

#ingress/inbound rule to allow inbound SSH traffic from the VPC CIDR block and allow inbound HTTP traffic from the ALB security group
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.apci_jupiter_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# allow HTTP traffic from the ALB security group
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb" {
  security_group_id = aws_security_group.apci_jupiter_app_sg.id
  referenced_security_group_id = var.apci_jupiter_alb_sg
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



# CREATING LAUNCH TEMPLATE FOR JUPITER SERVER----------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "apci_jupiter_lt" {
  name_prefix   = "apci-jupiter-lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  #user_data to run the script to install jupyter notebook on the instance at the time of launch.
  user_data = base64encode(file("scripts/jupiter-app.sh"))

    network_interfaces {
    associate_public_ip_address = true # to assign a public IP address to the instance
    security_groups = [aws_security_group.apci_jupiter_app_sg.id] # attach the security group created above to the instance
    
  }
}


# CREATING AUTO SCALING GROUP FOR JUPITER SERVER---------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "apci_jupiter_asg" {
  name                      = "apci-jupiter-asg"
  max_size                  = 6
  desired_capacity          = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
 
  force_delete              = true
  vpc_zone_identifier       = [var.apci_jupiter_public_subnet_az_1a, var.apci_jupiter_public_subnet_az_1c]
  target_group_arns         = [var.apci_jupiter_tg]

  launch_template {
    id      = aws_launch_template.apci_jupiter_lt.id # Reference the launch template created above
    version = "$Latest" # Use the latest version of the launch template number(1.2.3..)

  }
  tag {
    key                 = "Name"
    value               = "apci-jupiter-app-server"
    propagate_at_launch = true # to propagate the tag to the instances launched by the ASG
  }
}