variable "env" {
  type = string

}

variable "allowed_ip_addresses" {
  type    = list(string)
  default = []
}