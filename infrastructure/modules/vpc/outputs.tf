output "public_subnets_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnets_ids" {
  value = aws_subnet.private[*].id
}

output "id" {
  value = aws_vpc.this.id
}

output "allow_all_egress_sg_id" {
  value = aws_security_group.allow_all.id
}

output "allow_http_https_ingress_sg_id" {
  value = aws_security_group.allow_http_https_ingress.id
}
