variable "do_token" {}

variable "cluster_version" {
  type = string
  default = "1.20"
}

variable "worker_count" {
  type = number
}

variable "worker_size" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}