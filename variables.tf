variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  default     = "ami-0447a12f28fddb066"
}

variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

variable "bucket_name" {
  description = "S3 bucket name for logs"
}

variable "key_name" {
  description = "SSH key pair name"
}
