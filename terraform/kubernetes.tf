resource "google_container_cluster" "default" {
  depends_on         = [google_project_service.container-api]
  name               = "fullstaq-ruby"
  location           = "us-east1-c"
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Use VPC-native IPs
  ip_allocation_policy {}

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  pod_security_policy_config {
    enabled = true
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }

  release_channel {
    channel = "STABLE"
  }
}

resource "google_container_node_pool" "default" {
  name       = "fullstaq-ruby-default-node-pool"
  location   = google_container_cluster.default.location
  cluster    = google_container_cluster.default.name
  node_count = 1

  node_config {
    machine_type    = "g1-small"
    disk_size_gb    = 20
    disk_type       = "pd-standard"
    service_account = google_service_account.kubernetes.email

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "google_container_node_pool" "preemptible" {
  name       = "fullstaq-ruby-preemptible-node-pool"
  location   = google_container_cluster.default.location
  cluster    = google_container_cluster.default.name
  node_count = 1

  node_config {
    machine_type    = "g1-small"
    disk_size_gb    = 20
    disk_type       = "pd-standard"
    service_account = google_service_account.kubernetes.email
    preemptible     = true

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
