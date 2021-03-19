output "instance_id" {
  value = "${aws_instance.poke_around.id}"
}

output "instance_key_name" {
  value = "${aws_instance.poke_around.key_name}"
}

output "instance_public_dns" {
  value = "${aws_instance.poke_around.public_dns}"
}

output "instance_public_ip" {
  value = "${aws_instance.poke_around.public_ip}"
}
