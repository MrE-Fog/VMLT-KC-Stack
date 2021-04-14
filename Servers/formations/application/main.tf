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

resource "helm_release" "vapor_application" {
  name       = "vapor-application"
  chart      = "${path.module}/../../charts+values/vapor-application"
  namespace = var.namespace
}

# Use this to get the load balancer external IP for DNS configuration
data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = var.namespace
  }
  depends_on = [helm_release.vapor_application]
}

resource "digitalocean_record" "subdomain" {
  domain = "thecb4.io"
  type = "A"
  name = "vapor-blog"
  # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress
  value =  data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip

  depends_on = [
    data.kubernetes_service.traefik
  ]
}
