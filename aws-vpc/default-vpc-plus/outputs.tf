output "default_vpc_id" {
  value = "${data.aws_vpc.default.id}"
}

output "default_availability_zones" {
  value = "${data.aws_availability_zones.available.names}"
}

output "default_public_subnets" {
  value = "${data.aws_subnet_ids.default_public_subnets.ids}"
}

output "default_internet_gateway" {
  value = "${data.aws_internet_gateway.default_igw.internet_gateway_id}"
}

output "private_route_table" {
  value = "${aws_route_table.private_route_table.id}"
}

output "private_nat_gateway" {
  value = "${aws_nat_gateway.private_nat_gw.id}"
}

output "private_nat_gateway_eip" {
  value = "${aws_eip.nat_gw_eip.public_ip}"
}

output "private_subnet_2a" {
  value = "${aws_subnet.private_subnet_2a.id}"
}

output "private_subnet_2b" {
  value = "${aws_subnet.private_subnet_2b.id}"
}

output "private_subnet_2c" {
  value = "${aws_subnet.private_subnet_2c.id}"
}
