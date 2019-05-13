provider "aws" {
  version = "~> 2.10"
  region = "ap-southeast-2"
}

locals {
  lb_dns_name = "${element(concat(aws_lb.main.*.dns_name), 0)}"
}

variable "app_domain_name" {
  default = "dev.kholix.com"
}


//--- default VPC

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}


//--- ACM

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.app_domain_name}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}


//--- Route53

data "aws_route53_zone" "zone" {
  name         = "${var.app_domain_name}."
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}


resource "aws_route53_record" "app_dns_record" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name = "${var.app_domain_name}"
  type = "A"

  alias {
    name = "${local.lb_dns_name}"
    zone_id = "${aws_lb.main.zone_id}"
    evaluate_target_health = true
  }
}


//--- ALB

resource "aws_lb" "main" {
  name = "demo-app-alb"
  subnets = ["${data.aws_subnet_ids.all.ids}"]
  security_groups = ["${aws_security_group.alb_inbound_sg.id}"]
}

resource "aws_lb_target_group" "app" {
  name = "demo-app-target-group"
  port = 8000
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.default.id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.app.arn}"
  }

  depends_on = ["aws_lb_target_group.app"]
}

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "alb_inbound_sg" {
  name = "demo-app-alb-inbound-sg"
  description = "ELB Allowed Ports created by demo app"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
