resource "kubernetes_deployment_v1" "kuber" {
  metadata {
    labels = {
      app = local.instance_name
    }
    name      = local.instance_name
    namespace = var.namespace
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        network = var.network
        role    = "kuber"
      }
    }

    template {
      metadata {
        labels = {
          network = var.network
          role    = "kuber"
        }
      }

      spec {
        container {
          args = [
            "-d",
            "UNIX-LISTEN:/node-ipc/node.socket,fork,reuseaddr,unlink-early",
            "TCP:${local.node_n2n_tcp_endpoint}",
          ]

          image = "alpine/socat:latest"

          name = "socat"

          volume_mount {
            mount_path = "/node-ipc"
            name       = "cardanoipc"
          }
        }

        container {
          name = "kuber"

          image = "dquadrant/kuber:${var.kuber_image_tag}"

          resources {
            limits   = var.kuber_resources.limits
            requests = var.kuber_resources.requests
          }

          port {
            container_port = 8081
            name           = "http"
          }

          env {
            name  = "NETWORK"
            value = var.network
          }

          env {
            name  = "CARDANO_NODE_SOCKET_PATH"
            value = "/node-ipc/node.socket"
          }

          volume_mount {
            mount_path = "/node-ipc"
            name       = "cardanoipc"
          }
        }

        volume {
          name = "cardanoipc"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "kuber" {
  metadata {
    namespace = var.namespace
    name      = local.instance_name
  }
  spec {
    selector = {
      network = var.network
      role    = "kuber"
    }

    port {
      name        = "http"
      port        = 8081
      target_port = 8081
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_ingress_v1" "kuber" {
  wait_for_load_balancer = true
  metadata {
    name      = local.instance_name
    namespace = var.namespace
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "kuber-${var.network}.${var.dns_zone}"
      http {
        path {
          path = "/"

          backend {
            service {
              name = "kuber-${var.network}"
              port {
                number = 8081
              }
            }
          }
        }
      }
    }
    tls {
      hosts = ["*.${var.dns_zone}"]
    }
  }
}
