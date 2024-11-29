################## Providers #####################
provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us_east_1"  
  region = "us-east-1"  
}


######################################################################################################
##################################"""Mumbai"""##################################

################# Mumbai VPC ######################
resource "aws_vpc" "mumbai" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "mumbai"
  }
}

################ Mumbai IGW #######################
resource "aws_internet_gateway" "mumbai-igw" {
  vpc_id = aws_vpc.mumbai.id

  tags = {
    Name = "Mumbai-IGW"
  }
}

################### Public Subnet ###################
resource "aws_subnet" "mumbai-public" {
  vpc_id     = aws_vpc.mumbai.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Public-Mumbai"
  }
}

################# Private Subnet #################
resource "aws_subnet" "mumbai-private" {
  vpc_id     = aws_vpc.mumbai.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Private-Mumbai"
  }
}

################# Route Table Public ###################
resource "aws_route_table" "mum-pub-rt" {
  vpc_id = aws_vpc.mumbai.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai-igw.id
  }

  tags = {
    Name = "mumbai-rt-public"
  }
}

################# Route Table Private ##################
resource "aws_route_table" "mum-pri-rt" {
  vpc_id = aws_vpc.mumbai.id

  route {
    gateway_id = aws_vpc_peering_connection.peering.id
    cidr_block = aws_subnet.nvir-private.cidr_block
  }

  tags = {
    Name = "mumbai-rt-private"
  }
}

################# Route Table Associations #######################
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.mumbai-public.id
  route_table_id = aws_route_table.mum-pub-rt.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.mumbai-private.id
  route_table_id = aws_route_table.mum-pri-rt.id
}

########################Security-group-MUM########################################
resource "aws_security_group" "ec2_security_group_mumbai" {
  name        = "ec2_security_group_mumbai"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.mumbai.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (you can restrict this if needed)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

###################Mumbai-key-pair##########################
###################ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa###################
resource "aws_key_pair" "mumbai_key_pair" {
  key_name   = "mumbai-key-pair"  
  public_key = file("~/.ssh/id_rsa.pub")  
}

#####################################################################################################
########################################"""NVIR"""##########################################

################## NVIR VPC ############################
resource "aws_vpc" "nvir" {
  provider = aws.us_east_1 
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "NVIR"
  }
}

################ NVIR IGW #######################
resource "aws_internet_gateway" "nvir-igw" {
  vpc_id = aws_vpc.nvir.id
  provider = aws.us_east_1 
  tags = {
    Name = "NVIR-IGW"
  }
}

################### Public Subnet ###################
resource "aws_subnet" "nvir-public" {
  vpc_id     = aws_vpc.nvir.id
  provider = aws.us_east_1 
  cidr_block = "10.20.1.0/24"

  tags = {
    Name = "Public-NVIR"
  }
}

################# Private Subnet #################
resource "aws_subnet" "nvir-private" {
  vpc_id     = aws_vpc.nvir.id
  provider = aws.us_east_1 
  cidr_block = "10.20.2.0/24"
  tags = {
    Name = "Private-NVIR"
  }
}

################# Route Table Public ###################
resource "aws_route_table" "nvir-pub-rt" {
  vpc_id = aws_vpc.nvir.id
  provider = aws.us_east_1 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nvir-igw.id
  }

  tags = {
    Name = "nvir-rt-public"
  }
}

################# Route Table Private ##################
resource "aws_route_table" "nvir-pri-rt" {
  vpc_id = aws_vpc.nvir.id
  provider = aws.us_east_1 
  route {
    gateway_id = aws_vpc_peering_connection.peering.id
    cidr_block = aws_subnet.mumbai-private.cidr_block
  }
  tags = {
    Name = "nvir-rt-private"
  }
}

################# Route Table Associations #######################
resource "aws_route_table_association" "public_association_nvir" {
  provider = aws.us_east_1 
  subnet_id      = aws_subnet.nvir-public.id
  route_table_id = aws_route_table.nvir-pub-rt.id

}

resource "aws_route_table_association" "private_association_nvir" {
  provider = aws.us_east_1 
  subnet_id      = aws_subnet.nvir-private.id
  route_table_id = aws_route_table.nvir-pri-rt.id
}

########################Security-group-NVIR########################################
resource "aws_security_group" "ec2_security_group_useast" {
  provider    = aws.us_east_1
  name        = "ec2_security_group_useast"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.nvir.id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

####################NVIR-key-pair#######################
###################ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa###################
resource "aws_key_pair" "nvir_key_pair" {
  provider   = aws.us_east_1
  key_name   = "nvir-key-pair"  
  public_key = file("~/.ssh/id_rsa.pub") 
}

###############################################################################################
################## Peering Connection ############################
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.mumbai.id
  peer_vpc_id = aws_vpc.nvir.id
  peer_region = "us-east-1"
   tags = {
    Name = "peering-mum-nvir"
  }
}
resource "aws_vpc_peering_connection_accepter" "peering" {
  provider                  = aws.us_east_1
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  auto_accept               = true
}

##########################################################################################
#####################Public-machine-Mumbai#######################

resource "aws_instance" "mumbai_ec2_instance" {
  ami           = "ami-0327f51db613d7bd2" 
  instance_type = "t2.micro"   
  subnet_id     = aws_subnet.mumbai-public.id
  key_name      = aws_key_pair.mumbai_key_pair.key_name  
  vpc_security_group_ids = [aws_security_group.ec2_security_group_mumbai.id]

  associate_public_ip_address = true

  tags = {
    Name = "Mumbai Public EC2 Instance"
  }
}

#####################Private-machine-Mumbai#######################

resource "aws_instance" "mumbai_ec2_instance_private" {
  ami           = "ami-0327f51db613d7bd2" 
  instance_type = "t2.micro"   
  subnet_id     = aws_subnet.mumbai-private.id
  key_name      = aws_key_pair.mumbai_key_pair.key_name  
  vpc_security_group_ids = [aws_security_group.ec2_security_group_mumbai.id]

  associate_public_ip_address = false

  tags = {
    Name = "Mumbai Private EC2 Instance"
   }

  provisioner "remote-exec" {
    inline = [
      "sudo su -",
      "echo '${file("~/.ssh/id_rsa")}' > ~/.ssh/id_rsa",  
      "chmod 600 ~/.ssh/id_rsa"
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.mumbai_ec2_instance.public_ip 
      user        = "ec2-user"  
      private_key = file("~/.ssh/id_rsa")  
  }
  }
}



