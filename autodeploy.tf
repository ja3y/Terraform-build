

#create a VPC
##Create an internet gateway
#Create custom route atble
#create a subnet
#Associate subnet with route table
#Create a security group to allow port 22,80 & 443
#Create a netwoek interface with an ip in the subnet created in step 4
#Assign an eslastic IP to the network interface in step 7
#Create ubuntu server and install/enable apache2


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "Access key"
  secret_key = "Secret key"

}


#create a VPC
resource "aws_vpc" "cynet" {
  cidr_block =  "10.0.0.0/16"
  tags = {
    name = "production"
  }
}
#create a subnet
resource "aws_subnet" "cynet_sub1" {
  vpc_id = aws_vpc.cynet.id
  cidr_block = "10.0.1.0/24"
  #availability_zone = "us-east-1a"
  tags = {
    Name = "prod-subnet"
  }
}
#create an internet gateway
resource "aws_internet_gateway" "cynet_gateway" {
  vpc_id = aws_vpc.cynet.id
  tags = {
    Name = "cynetgw"
  } 
}
#create  a default route
resource "aws_route_table" "cynet_route" {
  vpc_id = aws_vpc.cynet.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cynet_gateway.id
  }
  tags = {
    Name = "cynet_route"
  }
}
resource "aws_route_table_association" "cynet_association" {
  subnet_id = aws_subnet.cynet_sub1.id
  route_table_id = aws_route_table.cynet_route.id

}
resource "aws_security_group" "cynet_allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cynet.id
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}
resource "aws_security_group" "cynet_allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.cynet.id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}
resource "aws_network_interface" "cynet_test" {
  subnet_id       = aws_subnet.cynet_sub1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.cynet_allow_tls.id, aws_security_group.cynet_allow_http.id]


}
resource "aws_eip" "cynet_pubip" {
  vpc                       = true
  network_interface         = aws_network_interface.cynet_test.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.cynet_gateway
  ]
}
resource "aws_instance" "ubuntu_server" {
  ami = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  #availability_zone = "us-east-1a"
  key_name = "cybernet-keypair"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.cynet_test.id
  }
  tags = {
    name = "ubuntu server"
  }
  user_data = <<-EOF
          #!/bin/bash
          sudo apt update -y
          sudo apt install apache2
          sudo systemctl start apache2
          sudo bash -c "Welcome home" > /var/www/html/index.html
          EOF
}



  



