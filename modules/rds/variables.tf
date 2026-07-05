variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  default = "laravel_nagoyameshi"
}

variable "db_username" {
  default = "admin"
}

variable "env" {
  type = string

}

variable "project_name" {
  type = string
}

variable "rds_sg_id" {
  type = string
}