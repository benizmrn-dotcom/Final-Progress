variable "REPOSITORY_URI" {
  type = string
}

variable "project_name" {
  type = string
}

variable "github_repository_url" {
  type = string
}

variable "codestar_connection_arn" {
  type = string
}

variable "env" {
  type = string
  
}

variable "subnets" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "cluster_name" {
  type = string
  
}

variable "service_name" {
  type = string
  
}

variable "branch" {
  type = string
  
}