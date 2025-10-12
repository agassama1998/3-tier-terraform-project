variable "tags" {
  type = map(string)
}



variable "vpc_cidr_block" {
  type = string
}



variable "public_subnet_cidr_block" {
  type = list(string)
  
}



variable "private_subnet_cidr_block" {
  type = list(string)
  
}



variable "db_subnet_cidr_block" {
  type = list(string)
  
}



variable "availability_zone" {
  type = list(string)
  
}