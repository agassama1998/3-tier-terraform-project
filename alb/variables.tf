variable "vpc_id" {
  type = string    #in terraform all ids are considered strings
}


variable "apci_jupiter_public_subnet_az_1a" {
  type = string  
}

variable "apci_jupiter_public_subnet_az_1c" {
  type = string 
}

variable "tags" {
  type = map(string)
}

variable "ssl_policy" {
  type = string
}

variable "certificate_arn" {
  type = string
}