variable "github_owner" {
  type = string
}

variable "github_branch" {
  type = string

}

variable "alert_email" {
  type = string
  
}

variable "env" {
  type = string
  
}

variable "hosted_zone_id" {
  type = string
  
}

variable "project_name" {
  type = string
}

variable "domain_name" {
  type = string
  
}

variable "app_domain_name" {
  type = string
}

variable "alb_origin_domain_name" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "app_key" {
  type      = string
  sensitive = true
}

variable "allowed_ip_addresses" {
  type = list(string)
}

variable "mail_username" {
  type = string
  
}

variable "mail_password" {
  type = string
  
}

variable "mail_from_address" {
  type = string
  
}