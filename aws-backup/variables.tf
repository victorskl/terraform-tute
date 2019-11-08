variable "region" {
  default = "ap-southeast-2"
}

variable "stack" {
  default = "myapp"
}

variable "env_name" {
  default = "prod"
}

variable "default_tags" {
  type = "map"
  default = {
    "Stack"       = "myapp"
    "Environment" = "prod"
    "Creator"     = "terraform"
  }
}

variable "restore_from_snapshot" {
  default = false
}

variable "snapshot_identifier" {
  default = ""
}

variable "db_instance_class" {
  default = "db.t2.micro"
}

variable "db_allocated_storage" {
  description = "Provide db storage size to use e.g. 10 (for 10GB)"
  default = 5
}
