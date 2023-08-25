terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "bucket-proj1-aug2023"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "dynamodb-table-proj1"
  }
}
  provider "aws" {
    region = "us-east-1"
  }
  resource "aws_vpc" "vpc_proj1"{
    cidr_block = "192.168.0.0/16"
    tags = {
      Name = "vpc_proj1"
    }
  }
resource "aws_subnet" "public1_proj1" {
  vpc_id = aws_vpc.vpc_proj1.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1c"
  tags ={
    Name = "public1_proj1"
  }
}
resource "aws_subnet" "public2_proj1" {
vpc_id = aws_vpc.vpc_proj1.id
cidr_block = "192.168.2.0/24"
availability_zone = "us-east-1d"
tags = {
  Name = "public2_proj1"
}
}
resource "aws_subnet" "private1_proj1" {
vpc_id = aws_vpc.vpc_proj1.id
cidr_block = "192.168.3.0/24"
availability_zone = "us-east-1e"
tags ={
  Name = "private1_proj1"
}  
}
resource "aws_subnet" "private2_proj1" {
vpc_id = aws_vpc.vpc_proj1.id
cidr_block = "192.168.4.0/24"
availability_zone = "us-east-1f"
tags ={
  Name = "private2_proj1"
}  
}
resource "aws_internet_gateway" "igw_proj1" {
  vpc_id = aws_vpc.vpc_proj1.id
tags = {
  Name = "igw_proj1"
}
}
resource "aws_route_table" "public_rt_proj1" {
vpc_id = aws_vpc.vpc_proj1.id
route{
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw_proj1.id
} 
tags = {
  Name = "public_rt_proj1"
}
}
resource "aws_route_table_association" "rt_assoc1_proj" {
  subnet_id = aws_subnet.public1_proj1.id
  route_table_id = aws_route_table.public_rt_proj1.id
  }
resource "aws_route_table_association" "rt_assoc2_proj" {
  subnet_id = aws_subnet.public2_proj1.id
  route_table_id = aws_route_table.public_rt_proj1.id
  
}
resource "aws_eip" "nat_ip_proj1" {
    domain = "vpc"
 }
 resource "aws_nat_gateway" "nat_gw_proj1" {
     allocation_id = aws_eip.nat_ip_proj1.id
     subnet_id = aws_subnet.public2_proj1.id
     tags = {
       Name = "nat_gw_proj1"
     }
   
 }
 resource "aws_eip" "ec2_eip_proj1" {
   vpc = true
 }
resource "aws_instance" "public1_ec2_proj1" {
  ami = "ami-08a52ddb321b32a8c"
  subnet_id = aws_subnet.public1_proj1.id
  instance_type = "t2.micro"
  tags = {
    Name = "Public_ec2_1"
  }
}
 resource "aws_eip_association" "eip_ec2_ass" {
   instance_id = aws_instance.public1_ec2_proj1.id
   allocation_id = aws_eip.ec2_eip_proj1.id
 }

resource "aws_db_subnet_group" "db_subnet_proj1" {
    name = "dbsubnetgrp"
    subnet_ids = [ aws_subnet.private1_proj1.id, aws_subnet.private2_proj1.id ]
    tags = {
      Name = "db_subnet_proj1"
    }
}
resource "aws_db_instance" "db_mysql_proj1" {
      allocated_storage = 20
      db_name = "db_mysql_proj1"
      engine = "mysql"
      engine_version = "8.0.33"
      instance_class = "db.t3.small"
      username = "user1"
      password = "password"
      multi_az = false    
      skip_final_snapshot = true   
      db_subnet_group_name = aws_db_subnet_group.db_subnet_proj1.id
  tags = {
    Name = "db_mysql_proj1"
   }
}