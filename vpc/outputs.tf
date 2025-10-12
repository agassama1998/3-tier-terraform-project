output "vpc_id" {
  value = aws_vpc.main_vpc.id
}


# Outputs for Public Subnets
output "apci_jupiter_public_subnet_az_1a" {
  value = aws_subnet.apci_jupiter_public_subnet_az_1a.id
}

output "apci_jupiter_public_subnet_az_1c" {
  value = aws_subnet.apci_jupiter_public_subnet_az_1c.id
}


# Additional outputs for private subnets
output "apci_jupiter_private_subnet_az_1a" {
  value = aws_subnet.apci_jupiter_private_subnet_az_1a.id
}

output "apci_jupiter_private_subnet_az_1c" {
  value = aws_subnet.apci_jupiter_private_subnet_az_1c.id
}


# Output for DB Subnet Group
output "apci_jupiter_db_subnet_az_1a" {
  value = aws_subnet.apci_jupiter_db_subnet_az_1a.id
}

output "apci_jupiter_db_subnet_az_1c" {
  value = aws_subnet.apci_jupiter_db_subnet_az_1c.id
}