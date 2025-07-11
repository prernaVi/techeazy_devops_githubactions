provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "techeazy_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "techeazy-vpc" }
}

resource "aws_subnet" "techeazy_subnet" {
  vpc_id                  = aws_vpc.techeazy_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = { Name = "techeazy-subnet" }
}

resource "aws_security_group" "instance_sg" {
  name        = "techeazy-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.techeazy_vpc.id

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

  tags = { Name = "techeazy-sg" }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id = "log-expiration"
    status = "Enabled"
    expiration { days = 7 }
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "techeazy-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "techeazy-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "techeazy_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.techeazy_subnet.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = file("${path.module}/scripts/setup.sh")

  tags = { Name = "techeazy-ec2" }
}

output "instance_public_ip" {
  value = aws_instance.techeazy_instance.public_ip
}
