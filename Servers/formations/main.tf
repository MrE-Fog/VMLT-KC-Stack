terraform {
  required_version = ">= 0.14"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}

# https://www.terraform.io/docs/language/modules/develop/providers.html

provider "digitalocean" {
  # Provider is configured using environment variables:
  # DIGITALOCEAN_TOKEN, DIGITALOCEAN_ACCESS_TOKEN
  token = var.do_token
}

locals {
  # cluster_name = "thecb4-k8s-${random_id.cluster_name.hex}"
  cluster_name = var.cluster_name
}

module "cluster" {
  source             = "./cluster/digital-ocean"
  do_token           = var.do_token
  cluster_name       = local.cluster_name
  cluster_region     = var.cluster_region

  worker_size        = var.worker_size
  worker_count       = var.worker_count
}

provider "kubernetes" {
  host             = module.cluster.info.endpoint
  token            = module.cluster.info.kube_config[0].token
  cluster_ca_certificate = base64decode(
    module.cluster.info.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host             = module.cluster.info.endpoint
    token            = module.cluster.info.kube_config[0].token
    cluster_ca_certificate = base64decode(
      module.cluster.info.kube_config[0].cluster_ca_certificate
    )
  }
}

resource "kubernetes_namespace" "solution" {
  metadata {
    name = "solution"
  }
}

module "proxy" {
  source   = "./proxy"
  namespace = kubernetes_namespace.solution.metadata.0.name
  depends_on = [module.cluster]
}

module "storage" {
  source   = "./storage"
  depends_on = [module.cluster]
}

# It takes a while for ceph to get working
resource "time_sleep" "wait_for_ceph" {
  depends_on = [module.storage]
  create_duration = "300s"
}

module "database" {
  source   = "./database"
  namespace = kubernetes_namespace.solution.metadata.0.name
  depends_on = [time_sleep.wait_for_ceph]
}

module "application" {
  source   = "./application"
  namespace = kubernetes_namespace.solution.metadata.0.name
  depends_on = [module.database]
}

