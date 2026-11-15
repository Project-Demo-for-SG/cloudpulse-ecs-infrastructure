output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "s3_endpoint_prefix_list_id" {
  description = "Prefix list ID for the private S3 gateway endpoint."
  value       = aws_vpc_endpoint.s3.prefix_list_id
}
