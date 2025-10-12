
# for us to deploy the infrastructures and resources on AWS we need the main.tf file.
provider "aws" {
  region = "us-west-1"
}


# Configure the S3 backend for Terraform state storage
terraform {
  backend "s3" {
    bucket         = "tfstate-remote-backend-00" # replace with your S3 bucket name created from aws console
    key            = "jupiter/statefile"           # path within the bucket to store the state file
    region         = "us-west-1"                   # replace with your AWS region
    dynamodb_table = "jupiter-state-locking"  # replace with your DynamoDB table name created from aws console
    encrypt        = true
  }
}



# Defining common tags for the project
module "vpc" {
  source = "./vpc"
  tags   = local.project_tags
  #the below variables are defined in variable.tf file inside the vpc folder.
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  availability_zone         = var.availability_zone
  private_subnet_cidr_block = var.private_subnet_cidr_block
  db_subnet_cidr_block      = var.db_subnet_cidr_block


}


# Application Load Balancer module to create ALB, target group and security group for ALB
module "alb" {
  source = "./alb"
  tags   = local.project_tags # from locals.tf file in the root folder/module with the name project tag
  #the below variables are defined in variable.tf file inside the alb folder/module and the vpc module.
  vpc_id                           = module.vpc.vpc_id                           #reference the output value from vpc module
  apci_jupiter_public_subnet_az_1a = module.vpc.apci_jupiter_public_subnet_az_1a #reference the output value from vpc module
  apci_jupiter_public_subnet_az_1c = module.vpc.apci_jupiter_public_subnet_az_1c #reference the output value from vpc module
  ssl_policy                       = var.ssl_policy
  certificate_arn                  = var.certificate_arn

}

# Auto-scaling module to create launch configuration, auto-scaling group and attach it to the ALB target group
module "auto-scaling" {
  source = "./auto-scaling"
  #the below variables are defined in variable.tf file inside the auto-scaling folder/module and the vpc and alb module.
  vpc_id                           = module.vpc.vpc_id
  apci_jupiter_alb_sg              = module.alb.apci_jupiter_alb_sg
  image_id                         = var.image_id
  instance_type                    = var.instance_type
  key_name                         = var.key_name
  apci_jupiter_public_subnet_az_1a = module.vpc.apci_jupiter_public_subnet_az_1a
  apci_jupiter_public_subnet_az_1c = module.vpc.apci_jupiter_public_subnet_az_1c
  apci_jupiter_tg                  = module.alb.apci_jupiter_tg

}

# Compute module to create bastion host and private server
module "compute" {
  source = "./compute"
  tags   = local.project_tags # from locals.tf file in the root folder/module with the name project tag
  #the below variables are defined in variable.tf file inside the compute folder/module and the vpc module.
  vpc_id                            = module.vpc.vpc_id                            #reference the output value from vpc module
  Image_id                          = var.image_id                                 # Amazon Linux 2 AMI ID, 
  instance_type                     = var.instance_type                            # t2.micro
  key_name                          = var.key_name                                 # key pair name "jupiter_keys"
  apci_jupiter_public_subnet_az_1a  = module.vpc.apci_jupiter_public_subnet_az_1a  #reference the output value from vpc module
  apci_jupiter_private_subnet_az_1a = module.vpc.apci_jupiter_private_subnet_az_1a #reference the output value from vpc module
  apci_jupiter_private_subnet_az_1c = module.vpc.apci_jupiter_private_subnet_az_1c #reference the output value from vpc module

}


# RDS module to create RDS instance and security group for RDS
module "rds" {
  source = "./rds"
  tags   = local.project_tags # from locals.tf file in the root folder/module with the name project tag
  #the below variables are defined in variable.tf file inside the rds folder/module and the vpc and compute module.
  vpc_id                       = module.vpc.vpc_id                            #reference the output value from vpc module
  apci_jupiter_db_subnet_az_1a = module.vpc.apci_jupiter_private_subnet_az_1a #reference the output value from vpc module
  apci_jupiter_db_subnet_az_1c = module.vpc.apci_jupiter_private_subnet_az_1c #reference the output value from vpc module
  apci_jupiter_bastion_sg      = module.compute.apci_jupiter_bastion_sg       #reference the output value from compute module
  db_username                  = var.db_username
  db_allocated_storage         = var.db_allocated_storage
  db_engine_version            = var.db_engine_version
  db_instance_class            = var.db_instance_class
  db_parameter_group_name      = var.db_parameter_group_name

}


# Route 53 module to create DNS record for the ALB
module "route53" {
  source = "./route53"
  #the below variables are defined in variable.tf file inside the route53 folder/module and the alb module.
  dns_zone_id               = var.dns_zone_id                      # Route 53 Hosted Zone ID
  dns_name                  = var.dns_name                         # Desired domain name (e.g., "example.com")
  apci_jupiter_alb_dns_name = module.alb.apci_jupiter_alb_dns_name #reference the output value from alb module
  apci_jupiter_alb_zone_id  = module.alb.apci_jupiter_alb_zone_id  #reference the output value from alb module

}