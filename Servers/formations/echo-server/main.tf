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
    # kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = ">= 1.7.0"
    # }
  }
}


resource "kubernetes_namespace" "echo" {
  metadata {
    name = "echo"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  cleanup_on_fail = true

}

resource "helm_release" "echo" {
  name       = "echo"
  chart      = "${path.module}/../../charts/echo-service"
  namespace = "echo"
}

# Use this to get the load balancer external IP for DNS configuration
data "kubernetes_service" "echo" {
  metadata {
    name      = "echo-service"
    namespace = kubernetes_namespace.echo.metadata.0.name
  }
  depends_on = [
    helm_release.ingress_nginx,
    helm_release.echo
  ]
}

resource "digitalocean_record" "echo" {
  domain = "thecb4.io"
  type = "A"
  name = "echo"
  # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress
  value =  data.kubernetes_service.echo.status.0.load_balancer.0.ingress.0.ip
}
