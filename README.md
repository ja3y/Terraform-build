# Terraform-build



This terraform script perform the following:

- Create a VPC
- Create an internet gateway
- Create custom route atble
- Create a subnet
- Associate subnet with route table
- Create a security group to allow port 22,80 & 443
- Create a netwoek interface with an ip in the subnet created in step 4
- Assign an eslastic IP to the network interface in step 7
- Create ubuntu server and install/enable apache2


Note: Generate your own access and secret keys and supply into the script as needed. 
