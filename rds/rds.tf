# Creating DB Subnet Group for RDS Instance -------------------------------------------------------------
resource "aws_db_subnet_group" "apci_jupiter_db_subnet_group" {
  name       = "jupiter-db-subnet-group"
  subnet_ids = [var.apci_jupiter_db_subnet_az_1a, var.apci_jupiter_db_subnet_az_1c]

    tags = merge(var.tags, {
        Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-group"
    })
}


# Creating Security Group for RDS database-------------------------------------------------------------
resource "aws_security_group" "apci_jupiter_rds_sg" {
  name        = "rds-sg"
  description = "Allow db traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "jupiter-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_traffic" {
  security_group_id = aws_security_group.apci_jupiter_rds_sg.id 
  referenced_security_group_id = var.apci_jupiter_bastion_sg  # referencing the bastion host security group to allow SSH access to RDS
  from_port         = 3306    # MySQL/Aurora port
  ip_protocol       = "tcp"
  to_port           = 3306    # MySQL/Aurora port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_db_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#REFERENCING AN EXISTING PASSWORD FROM SECRETS MANAGER -------------------------------------------------------------
data "aws_secretsmanager_secret" "apci_jupiter_rdsmysql_password" {
  name = "jupiterdb"      # Name of the secret in AWS Secrets Manager
}
data "aws_secretsmanager_secret_version" "apci_jupiter_secret_version" {
  secret_id     = data.aws_secretsmanager_secret.apci_jupiter_rdsmysql_password.id # Reference the secret created above
}


#CREATING RDS MYSQL DATABASE -------------------------------------------------------------
resource "aws_db_instance" "apci_jupiter_mysql_db" {
  allocated_storage    = var.db_allocated_storage
  db_name              = "mysqldb"
  engine               = "mysql"        # determines the exact database engine to use. In this case, it's MySQL.
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = jsondecode(data.aws_secretsmanager_secret_version.apci_jupiter_secret_version.secret_string)["mysql_password"] # In a production environment, consider using AWS Secrets Manager or SSM Parameter Store to manage sensitive information like passwords.
  parameter_group_name = var.db_parameter_group_name
  vpc_security_group_ids = [aws_security_group.apci_jupiter_rds_sg.id] # Attach the security group created above
  db_subnet_group_name = aws_db_subnet_group.apci_jupiter_db_subnet_group.name # Attach the DB subnet group created above
  skip_final_snapshot  = true
}