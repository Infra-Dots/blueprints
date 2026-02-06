provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

locals {
  network_name = "infradots-vpc"
  subnet_name  = "infradots-subnet"
}

################################################################################
# Network
################################################################################

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = local.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = local.subnet_name
      subnet_ip     = "10.0.0.0/24"
      subnet_region = var.region
    }
  ]
}

# Cloud NAT for private instances to access internet
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"

  name    = "infradots-router"
  project = var.project_id
  network = module.vpc.network_name
  region  = var.region

  nats = [{
    name = "infradots-nat"
  }]
}

################################################################################
# Cloud SQL (PostgreSQL)
################################################################################

# Private Service Access configuration for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta
  
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

module "sql" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 27.0"

  name             = "infradots-db"
  database_version = "POSTGRES_14"
  project_id       = var.project_id
  region           = var.region
  zone             = "${var.region}-a"

  # Tier db-f1-micro is deprecated/unavailable in some new regions, using modest standard
  tier = "db-custom-1-3840" 

  ip_configuration = {
    ipv4_enabled    = false
    private_network = module.vpc.network_self_link
  }

  db_name      = "appdb"
  user_name    = "user"
  user_password = var.db_password

  deletion_protection = false # For blueprint purposes

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

################################################################################
# Managed Instance Group (MIG)
################################################################################

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 14.0"

  project_id   = var.project_id
  subnetwork   = module.vpc.subnets_self_links[0]
  source_image = var.image
  machine_type = "e2-micro"
  
  service_account = {
    email  = "" # Use default compute service account
    scopes = ["cloud-platform"]
  }

  tags = ["allow-health-checks"]
  
  startup_script = <<EOF
    #! /bin/bash
    apt-get update
    apt-get install -y apache2
    echo "<h1>Hello from GCP MIG!</h1>" > /var/www/html/index.html
  EOF
}

module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 14.0"

  project_id        = var.project_id
  region            = var.region
  target_size       = 2
  hostname          = "infradots-vm"
  instance_template = module.instance_template.self_link
  
  named_ports = [{
    name = "http"
    port = 80
  }]
}

################################################################################
# Load Balancer
################################################################################

module "lb-http" {
  source  = "terraform-google-modules/lb-http/google"
  version = "~> 14.0"

  project = var.project_id
  name    = "infradots-lb"
  
  firewall_networks = [module.vpc.network_name]

  backends = {
    default-backend = {
      description                     = "Default backend"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      enable_cdn                      = false
      health_check = {
        check_interval_sec  = 10
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        port                = 80
        logging             = true
      }
      groups = [
        {
          group = module.mig.instance_group
        }
      ]

      # IAM: None for public LB
      iap_config = {
        enable = false
      }
      log_config = {
        enable = true
      }
    }
  }
}
