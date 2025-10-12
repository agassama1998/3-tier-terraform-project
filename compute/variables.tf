variable "vpc_id" {
  type = string
}

variable "Image_id" {
  type = string
}

variable "instance_type" {
  type    = string
}

variable "key_name" {
  type = string
}

# The public subnet_id in AZ 1a
variable "apci_jupiter_public_subnet_az_1a" { 
  type = string
}

variable "tags" {
  type = map(string)
}


# The private subnet_id in AZ 1a
variable "apci_jupiter_private_subnet_az_1a" {
  type = string
}
variable "apci_jupiter_private_subnet_az_1c" {
  type = string
}