variable "org_id" {
  type = string
  default = "636256323415"
}

variable "billing_account_id" {
  type    = string
  default = "01614C-82BAE7-678369"
}

variable "region" {
  type    = string
  default = "us-east4"
}

variable "zone" {
  type    = string
  default = "us-east4-a"
}

variable "existing_project" {
  type = bool
  default = true
}

variable "project_id" {
  type = string
  default = ""
}

variable "project_name" {
  type = string
  default = ""
}
