# Create a security group for BASTION HOST-------------------------------------------------
resource "aws_security_group" "apci_jupiter_bastion_sg" {
  name        = "apci-jupiter-bastion-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion_host_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22 # SSH port
  ip_protocol       = "tcp"
  to_port           = 22
}



resource "aws_vpc_security_group_egress_rule" "allow_all_ssh_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports meaning whatever comes in is 
  #allow to go out i.e (stateful) and the other way around is not true (stateless)
}


# CREATING A BASTION HOST EC2 instance-------------------------------------------------
resource "aws_instance" "apci_jupiter_bastion_host" {
  ami           = var.Image_id        # The Image_id the operating system for the instance Amazon Linux 2 AMI ID, 
  instance_type = var.instance_type   # t2.micro
  key_name      = var.key_name        # key pair name "jupiter_keys"
  associate_public_ip_address = true  # Assign a public IP address to the instance
  subnet_id = var.apci_jupiter_public_subnet_az_1a # Subnet ID where the instance will be launched
  security_groups = [aws_security_group.apci_jupiter_bastion_sg.id] # Security group ID to associate with the instance

    tags = merge(var.tags, {
        Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host"
    })
}


# Create a security group for private server-------------------------------------------------
resource "aws_security_group" "apci_jupiter_private_server_sg" {
  name        = "private-server-sg"
  description = "Allow SSH traffic from bastion host"
  vpc_id      = var.vpc_id

  tags = {
    Name = "private_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_bastion_host" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id
  referenced_security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  from_port         = 22 # SSH port
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_bastion_ssh_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports meaning whatever comes in is 
  #allow to go out i.e (stateful) and the other way around is not true (stateless)
}


# CREATING A PRIVATE SERVER FOR AZ 1A / EC2 instance-------------------------------------------------
resource "aws_instance" "apci_jupiter_private_server_az_1a" {
  ami           = var.Image_id        # The Image_id the operating system for the instance Amazon Linux 2 AMI ID, 
  instance_type = var.instance_type   # t2.micro
  key_name      = var.key_name        # key pair name "jupiter_keys"
  associate_public_ip_address = false  # Do not Assign a public IP address to the instance
  subnet_id = var.apci_jupiter_private_subnet_az_1a # Subnet ID where the instance will be launched
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id] # Security group ID to associate with the instance

    tags = merge(var.tags, {
        Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-1a"
    })
}


# CREATING A PRIVATE SERVER FOR AZ 1C / EC2 instance-------------------------------------------------
resource "aws_instance" "apci_jupiter_private_server_az_1c" {
  ami           = var.Image_id        # The Image_id the operating system for the instance Amazon Linux 2 AMI ID, 
  instance_type = var.instance_type   # t2.micro
  key_name      = var.key_name        # key pair name "jupiter_keys"
  associate_public_ip_address = false  # Do not Assign a public IP address to the instance
  subnet_id = var.apci_jupiter_private_subnet_az_1c # Subnet ID where the instance will be launched
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id] # Security group ID to associate with the instance

    tags = merge(var.tags, {
        Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-1c"
    })
}

