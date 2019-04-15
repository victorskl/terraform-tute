# output Elastic IPs
output "ip" {
  value = "${aws_eip.ip.public_ip}"
}
