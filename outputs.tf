
output "bucket_name" {
  description = "S3 bucket name used for logs"
  value       = aws_s3_bucket.log_bucket.bucket
}

output "vpc_id" {
  description = "VPC ID created for the TechEazy project"
  value       = aws_vpc.techeazy_vpc.id
}

output "subnet_id" {
  description = "Subnet ID created for the TechEazy project"
  value       = aws_subnet.techeazy_subnet.id
}
