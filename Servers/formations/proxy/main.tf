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

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  namespace = "solution"

  values = [
    file("${path.module}/../../charts+values/traefik-proxy/values.yaml")
  ]

  atomic = true
  timeout = 600
  cleanup_on_fail = true
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace = "solution"

  values = [
    file("${path.module}/../../charts+values/cert-manager/values.yaml")
  ]

  atomic = true
  timeout = 600
  cleanup_on_fail = true

  depends_on = [helm_release.traefik]
}


# Use this to get the load balancer external IP for DNS configuration
data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "solution"
  }

  depends_on = [helm_release.cert_manager]
}

resource "digitalocean_record" "subdomain" {
  domain = "thecb4.io"
  type = "A"
  name = "traefik"
  # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress
  value =  data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip

  depends_on = [
    data.kubernetes_service.traefik
  ]
}

resource "helm_release" "proxy_dashboard" {
  name       = "proxy-dashboard"
  chart      = "${path.module}/../../charts+values/proxy-dashboard"
  namespace = var.namespace

  depends_on = [
    digitalocean_record.subdomain
  ]

}
