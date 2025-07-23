provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "ec2-sg-${random_id.sg_suffix.hex}"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "techeazy_instance" {
  ami                    = "ami-0447a12f28fddb066"
  instance_type          = "t2.micro"
  key_name               = "prerna-key-new"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  
  tags = {
      Name = "my-terraform-ec2"
    }
  }
  resource "random_id" "sg_suffix" {
      byte_length = 4
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install java-openjdk11 -y
              yum install git -y
              cd /home/ec2-user
              git clone https://github.com/prernaVi/techeazy_devops_githubactions.git app
              cd app
              chmod +x mvnw
              ./mvnw package
              java -jar target/*.jar --server.port=80
              EOF
}

output "instance_public_ip" {
  value = aws_instance.techeazy_instance.public_ip
}



