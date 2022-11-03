terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
}

variable "namespace" {}

variable "kuber_image_tag" {
  default = "2.1.0"
}

variable "network" {}

variable "disk_iops" {
  default = "3000"
}

variable "disk_throughput" {
  default = "125"
}

variable "disk_size" {
  default = "20Gi"
}

variable "kuber_resources" {
  type = object({
    requests = map(string)
    limits   = map(string)
  })

  default = {
    "limits" = {
      "memory" = "4Gi"
    }
    "requests" = {
      "memory" = "4Gi"
      "cpu"    = "500m"
    }
  }
}


locals {
  node_n2n_tcp_endpoint = "node-${var.network}-1-35-3-0.nodes.ftr-nodes-v0.svc.cluster.local:3307"
  kuber_host            = "dmtr-${var.network}-kuber"
  kuber_name           = "${var.network}-kuber"
}