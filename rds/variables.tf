# Creating Variables for DB Subnet Group -------------------------------------------------------------
variable "apci_jupiter_db_subnet_az_1a" {
  type = string
}
variable "apci_jupiter_db_subnet_az_1c" {
  type = string
}


variable "tags" {
  type = map(string)    
}

variable "vpc_id" {
  type = string
}

variable "apci_jupiter_bastion_sg" {
  type = string
}


variable "db_username" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}
variable "db_parameter_group_name" {
  type = string
}