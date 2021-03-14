variable "admin_password" {
  type      = string
  sensitive = true
}

variable "enabled" {
  type      = bool
  default   = true
}
