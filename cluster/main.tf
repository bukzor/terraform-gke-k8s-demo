variable name {}
variable network {}
variable zone {}
variable ip_cidr_range {}

locals {
  region = "${join("-", slice(split("-", var.zone), 0, 2))}"
}

resource google_compute_subnetwork "_" {
  name          = "${var.name}"
  region        = "${local.region}"
  network       = "${var.network}"
  ip_cidr_range = "${var.ip_cidr_range}"
}

resource google_container_cluster "_" {
  name               = "${var.name}"
  zone               = "${var.zone}"
  network            = "${var.network}"
  subnetwork         = "${google_compute_subnetwork._.self_link}"
  initial_node_count = 1
}

provider "kubernetes" {
  host = "https://${google_container_cluster._.endpoint}"

  username = "${google_container_cluster._.master_auth.0.username}"
  password = "${google_container_cluster._.master_auth.0.password}"

  client_key             = "${base64decode(google_container_cluster._.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster._.master_auth.0.cluster_ca_certificate)}"
}

resource "kubernetes_deployment" "_" {
  provider = "kubernetes"

  metadata {
    name = "hello-node"
  }

  spec {
    selector {
      match_labels {
        app = "hello-node"
      }
    }

    template {
      metadata {
        labels {
          app = "hello-node"
        }
      }

      spec {
        container {
          name  = "hello-node"
          image = "gcr.io/hello-minikube-zero-install/hello-node"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "_" {
  metadata {
    name      = "hello-node-service"
    namespace = "default"
  }

  spec {
    type = "LoadBalancer"

    selector {
      app = "hello-node"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }
  }
}
