terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
}

variable "namespace" {}

variable "network" {}

variable "dns_zone" {}

variable "replicas" {
  default = 1
}

variable "kuber_image_tag" {
  default = "2.2.0"
}

variable "kuber_resources" {
  type = object({
    requests = map(string)
    limits   = map(string)
  })

  default = {
    "limits" = {
      "memory" = "1Gi"
    }
    "requests" = {
      "memory" = "500Mi"
      "cpu"    = "500m"
    }
  }
}


locals {
  node_n2n_tcp_endpoint = "node-${var.network}-1-35-3-0.nodes.ftr-nodes-v0.svc.cluster.local:3307"
  instance_name         = "kuber-${var.network}"
}
