variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "app_image" {
  type = string
}

variable "app_url" {
  type = string
}

variable "env" {
  type = string
}

variable "db_database" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "ecs_security_groups" {
  type = list(string)
}

variable "desired_count" {
  type = number
}