# Configuring our network for Tenacity IT Group

# Create a VPC
resource "aws_vpc" "Prod_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Prod_vpc"
  }
}

# Creating a public subnet 
resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id            = aws_vpc.Prod_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

# Creating a public subnet 
resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id            = aws_vpc.Prod_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-pub-sub2"
  }
}

# Creating a private subnet 
resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id            = aws_vpc.Prod_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

# Creating a private subnet 
resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id            = aws_vpc.Prod_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-sub2"
  }
}

# Creating a public route table
resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.Prod_vpc.id

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# Associate public subnets to route table
resource "aws_route_table_association" "Public_sub_association1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# Associate public subnets to route table
resource "aws_route_table_association" "Public_sub_association2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# Creating a private route table
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.Prod_vpc.id

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# Associate private subnets to route table
resource "aws_route_table_association" "Private_sub_association1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

# Associate private subnets to route table
resource "aws_route_table_association" "Private_sub_association2" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}


# Creating internet Gateway
resource "aws_internet_gateway" "Prod_igw" {
  vpc_id = aws_vpc.Prod_vpc.id

  tags = {
    Name = "Prod_igw"
  }
}

# Associate internet gateway to public subnets
resource "aws_route" "Prod-igw-association" {
  route_table_id         = aws_route_table.Prod-pub-route-table.id
  gateway_id             = aws_internet_gateway.Prod_igw.id
  destination_cidr_block = "0.0.0.0/0"

}


 # Create an elastic IP address
resource "aws_eip" "eip1" {
  vpc = true
  depends_on = [aws_internet_gateway.Prod_igw]
}

# Creating NAT gateway
resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.Prod-pub-sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }

  depends_on = [aws_internet_gateway.Prod_igw]
}
 
 # Associate NAT gateway to route table
 resource "aws_route" "Prod-Nat-association" {
  route_table_id         = aws_route_table.Prod-priv-route-table.id
  gateway_id             = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"

 }

