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

resource "helm_release" "mongodb_sharded" {
  name       = "mongo-k8s"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb-sharded"
  # version    = "v1.5.9"
  namespace = var.namespace

  cleanup_on_fail = true

  values = [
    file("${path.module}/../../charts+values/mongo-database/values.yaml")
  ]

}
