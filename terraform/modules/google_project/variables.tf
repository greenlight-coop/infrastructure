variable "region" {
  type    = string
}

variable "zone" {
  type    = string
}

variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "min_node_count" {
  type    = number
  default = 3
}

variable "max_node_count" {
  type    = number
  default = 10
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "preemptible" {
  type    = bool
  default = true
}

# List available versions:  gcloud container get-server-config --zone us-east4-a
variable "k8s_version" {
  type = string
  default = "1.18.16-gke.300"
}

variable "domain_name" {
  type = string
}
