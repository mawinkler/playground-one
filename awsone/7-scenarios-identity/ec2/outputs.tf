output "member_dns_names" {
  value = aws_instance.windows-server-member.*.public_dns
}
