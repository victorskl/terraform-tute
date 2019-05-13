provider "aws" {
  version = "~> 2.10"
  region = "ap-southeast-2"
}

variable "domain" {
  default = "dev.kholix.com"
}

resource "aws_route53_zone" "dev" {
  name = "${var.domain}"
}

output "nameservers" {
  value = "${aws_route53_zone.dev.name_servers}"
}
