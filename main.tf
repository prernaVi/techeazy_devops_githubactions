provider "aws" {
  region = "ap-south-1"
}

variable "logs_bucket_name" {
  description = "Name for the S3 logs bucket"
  default     = "techeazy-prerna-logs"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0a123456789abcdef"  # Replace with your valid AMI ID
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "default" {
  id = data.aws_subnet_ids.default.ids[0]
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name

  tags = {
    Name = "Logs Bucket"
  }
}

resource "aws_security_group" "ec2_sg_custom" {
  name        = "techeazy-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = {
    Name = "techeazy-ec2-sg"
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.ec2_sg_custom.id]

  tags = {
    Name = "techeazy-ec2-instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}

