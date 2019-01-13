provider google {
  project = "bukzor-demo-depprov-bug"
}

resource "google_project_services" "_" {
  services = [
    "logging.googleapis.com",           # Stackdriver Logging
    "oslogin.googleapis.com",           # GCE dep
    "pubsub.googleapis.com",            # GCE dep
    "compute.googleapis.com",           # GCE
    "bigquery-json.googleapis.com",     # GKE dep
    "storage-api.googleapis.com",       # GKE dep
    "containerregistry.googleapis.com", # GKE dep
    "container.googleapis.com",         # GKE
  ]
}

resource google_compute_network "_" {
  name                    = "worldwide"
  auto_create_subnetworks = "false"

  depends_on = ["google_project_services._"]
}

module "cluster--asia" {
  source = "cluster"

  name          = "asia"
  network       = "${google_compute_network._.self_link}"
  zone          = "asia-east1-b"
  ip_cidr_range = "10.0.0.0/16"
}

module "cluster--us" {
  source = "cluster"

  name          = "us"
  network       = "${google_compute_network._.self_link}"
  zone          = "us-central1-b"
  ip_cidr_range = "10.1.0.0/16"
}
