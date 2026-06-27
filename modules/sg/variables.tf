variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cloudfront_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}