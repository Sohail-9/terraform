resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr // Define the CIDR block for the VPC 65536 IP addresses
    tags = {
       name : "main"
    }
}

resource "aws_subnet" "subnet" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc.id
    tags = {
         name : "main-ig"
    }  
}

//route table association
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.vpc.id
    tags = {
         name : "main-rt"
    }  
}
resource "aws_route_table_association" "rta1" {
    subnet_id      = aws_subnet.subnet.id
    route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rta2" {
    subnet_id      = aws_subnet.subnet2.id
    route_table_id = aws_route_table.rt.id
}