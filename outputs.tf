output "vpc_id" {
  description = "id of the vpc"
  value       = concat(aws_vpc.vpc.*.id, [""])[0]
}

output "public_subnets" {
  description = "Public subnets IDs"
  value       = aws_subnet.public.*.id
}
