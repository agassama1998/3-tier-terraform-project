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

variable "image_id" {
  type = string
}


variable "instance_type" {
  type = string
}


variable "key_name" {
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

variable "dns_zone_id" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "certificate_arn" {
  type = string
}
