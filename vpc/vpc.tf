
#CREATING VPC ------------------------------------------------------------------------------------------ 
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default" 

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main-vpc"
  })
}


#CREATING INTERNET GATEWAY ------------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  # the formart of referencing the resource is resource_type.resource_name.attribute(id).
  vpc_id = aws_vpc.main_vpc.id   # attach the igw with the vpc.

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}


#CREATING 2 PUBLIC SUBNETS ---------------------------------------------------------------------------------------
# 1st PUBLIC SUBNET
resource "aws_subnet" "apci_jupiter_public_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]  # referencing the first element in the list of string.
  availability_zone = var.availability_zone[0]  # referencing the first element in the list of string.

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet_az_1a"
  })
}

# 2nd PUBLIC SUBNET
resource "aws_subnet" "apci_jupiter_public_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]  # referencing the second element in the list of string.
  availability_zone = var.availability_zone[1]  # referencing the second element in the list of string.

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet_az_1c"
  })
}



#CREATING 2 PRIVATE SUBNETS ---------------------------------------------------------------------------------------
# 1st PRIVATE SUBNET
resource "aws_subnet" "apci_jupiter_private_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]  # referencing the first element in the list of string of private subnet cidr block.
  availability_zone = var.availability_zone[0]  # referencing the first element in the list of string.

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_az_1a"
  })
}

# 2nd PRIVATE SUBNET
resource "aws_subnet" "apci_jupiter_private_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]  # referencing the second element in the list of string of private subnet cidr block.
  availability_zone = var.availability_zone[1]  # referencing the second element in the list of string.

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_az_1c"
  })
}


#CREATING 2 DATABASE SUBNETS  ---------------------------------------------------------------------------------------
# 1st DATABASE SUBNET
resource "aws_subnet" "apci_jupiter_db_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[0]  # referencing the first element in the list of string of db subnet cidr block.
  availability_zone = var.availability_zone[0]  # referencing the first element in the list of string.

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db_subnet_az_1a"
  })
}

# 2nd DATABASE SUBNET
resource "aws_subnet" "apci_jupiter_db_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[1]  # referencing the 2nd element in the list of string of db subnet cidr block.
  availability_zone = var.availability_zone[1]  # referencing the first 2nd element in the list of string.

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db_subnet_az_1c"
  })
}

#CREATING PUBLIC ROUTE TABLE ---------------------------------------------------------------------------------------
resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
}


#ASSOCIATING PUBLIC SUBNETS WITH PUBLIC ROUTE TABLE ---------------------------------------------------------------------------------------
# 1st PUBLIC ROUTE TABLE TO PUBLIC SUBNET ASSOCIATION
resource "aws_route_table_association" "public_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

# 2nd PUBLIC ROUTE TABLE TO PUBLIC SUBNET ASSOCIATION
resource "aws_route_table_association" "public_subnet_az_1c" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}



#CREATING AN ELASTIC IP FOR NAT GATEWAY ON AZ 1A -----------------------------------------------------------------------
resource "aws_eip" "eip_az_1a" {
  domain   = "vpc"

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1a"
  })
}


#CREATING NAT GATEWAY ON AZ 1A ---------------------------------------------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1a" {
  allocation_id = aws_eip.eip_az_1a.id # referencing the elastic IP created above.
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_1a.id # NAT GW must be created in a public subnet for internet access. 

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1a"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1a, aws_subnet.apci_jupiter_public_subnet_az_1a]
}

# CREATING PRIVATE ROUTE TABLE FOR AZ 1A ---------------------------------------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_1a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # routing all traffic to the NAT GW.
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1a.id # must be referencing the NAT GW created above.
  }

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1a"
  })
}
 

#ASSOCIATING PRIVATE SUBNETS WITH PRIVATE ROUTE TABLE ---------------------------------------------------------------------------------------
# 1st PRIVATE ROUTE TABLE TO PRIVATE SUBNET ASSOCIATION
resource "aws_route_table_association" "private_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id # referencing the private route table created above.
}

# CREATING DB SUBNET FOR AZ 1A -------------------------------------------------------------
resource "aws_route_table_association" "db_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id #referencing to the same private route table created above.
}