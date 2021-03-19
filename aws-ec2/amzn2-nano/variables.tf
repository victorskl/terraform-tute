variable "ami_id" {
  default = "ami-01ca411ebe9ce4a82" // amzn2-ami-minimal-hvm-2.0.20191024.3-x86_64-ebs
}

variable "instance_type" {
  default = "t3a.nano"
}

variable "your_ssh_key_pair_name" {}

variable "your_ssh_public_key" {}
