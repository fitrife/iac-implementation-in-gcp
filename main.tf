# VPC Network
resource "google_compute_network" "vpc_network" {
  name = "fitrife"
  auto_create_subnetworks = false
  mtu = 1460
}

# Subnet
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "fitri-subnetwork"
  ip_cidr_range = "172.16.0.0/16"
  region        = "northamerica-northeast2"
  network       = google_compute_network.vpc_network.self_link
  depends_on    = [ google_compute_network.vpc_network ]
}

# Static NAT IP untuk fitri-webserver
resource "google_compute_address" "webserver_nat_ip" {
  name   = "fitri-webserver-nat-ip"
  region = "northamerica-northeast2"
}

# VM Program
resource "google_compute_instance" "program" {
  name             = "fitri-program"
  zone             = "northamerica-northeast2-b"
  machine_type     = "e2-small"

  tags = [ "program" ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 30
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.network-with-private-secondary-ip-ranges.self_link
    network_ip = "172.16.21.1"
  }
}

# VM Webserver
resource "google_compute_instance" "webserver" {
  name             = "fitri-webserver"
  zone             = "northamerica-northeast2-c"
  machine_type     = "e2-small"

  tags = [ "webserver" ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 30
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.network-with-private-secondary-ip-ranges.self_link
    network_ip = "172.16.22.2"
    access_config {
      nat_ip = google_compute_address.webserver_nat_ip.address
    }
  }
}

# Firewall rule to open port 80 (HTTP) for fitri-webserver
resource "google_compute_firewall" "rules" {
  name        = "webserver-firewall-rule"
  network     = google_compute_network.vpc_network.name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["80"]
  }

  source_tags = ["webserver"]
  target_tags = ["webserver"]
}
