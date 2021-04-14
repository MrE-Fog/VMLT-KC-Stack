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

# Create namespace
resource "kubernetes_namespace" "rook-ceph" {
  metadata {
    name = "rook-ceph"
  }
}

resource "helm_release" "rook_ceph_operator" {
  name       = "rook-ceph"
  repository = "https://charts.rook.io/release"
  chart      = "rook-ceph"
  namespace = "rook-ceph"
  atomic = true
  timeout = 600
  cleanup_on_fail = true
}

resource "helm_release" "ceph-storage" {
  name       = "ceph-storage"
  chart      = "${path.module}/../../charts+values/ceph-storage"
  namespace = "rook-ceph"
  atomic = true
  timeout = 600
  cleanup_on_fail = true
  depends_on = [
    helm_release.rook_ceph_operator
  ]
}