variable "do_token" {}

variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "worker_count" {
  default = 3
}

variable "worker_size" {
  default = "s-2vcpu-4gb"
}
