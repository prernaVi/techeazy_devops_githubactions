provider "aws" {
  region = var.aws_region
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Use default subnets within the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ✅ Use existing techeazy-sg security group instead of creating
data "aws_security_group" "instance_sg" {
  filter {
    name   = "group-name"
    values = ["techeazy-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {} # required by AWS provider
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "techeazy-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
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
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [data.aws_security_group.instance_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = file("${path.module}/scripts/setup.sh")

  tags = { Name = "techeazy-ec2" }
}

output "instance_public_ip" {
  value = aws_instance.techeazy_instance.public_ip
}
