provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  cluster_name = "infradots-gke-${var.environment}"
}

################################################################################
# Network
################################################################################

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = "infradots-gke-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "gke-subnet"
      subnet_ip     = "10.0.0.0/24"
      subnet_region = var.region
    }
  ]

  secondary_ranges = {
    gke-subnet = [
      {
        range_name    = "ip-range-pods"
        ip_cidr_range = "10.1.0.0/16"
      },
      {
        range_name    = "ip-range-services"
        ip_cidr_range = "10.2.0.0/20"
      }
    ]
  }
}

################################################################################
# GKE Cluster
################################################################################

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 43.0"

  project_id        = var.project_id
  name              = local.cluster_name
  region            = var.region
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_pods     = "ip-range-pods"
  ip_range_services = "ip-range-services"

  create_service_account = true
  
  # Workload Identity
  workload_identity_config = true

  node_pools = [
    {
      name           = "default-node-pool"
      machine_type   = var.node_machine_type
      min_count      = 1
      max_count      = 3
      local_ssd_count = 0
      disk_size_gb   = 30
      disk_type      = "pd-standard"
      image_type     = "COS_CONTAINERD"
      enable_gcfs    = false
      enable_gvnic   = false
      auto_repair    = true
      auto_upgrade   = true
      preemptible    = false
      initial_node_count = 1
    },
  ]
}

data "google_client_config" "default" {}

################################################################################
# Workload Identity & IAM
################################################################################

# External DNS
module "external_dns_wi" {
  source  = "terraform-google-modules/iam/google//modules/workload_identity"
  version = "~> 8.2"

  name                            = "external-dns-wi"
  project_id                      = var.project_id
  roles                           = ["roles/dns.admin"]
  gcp_sa_name                     = "external-dns-sa"
  k8s_sa_name                     = "external-dns"
  namespace                       = "kube-system"
  annotate_k8s_sa                 = false # Helm handles annotation if we pass it, but module creates SA. Helm chart creates SA usually.
  # Strategy: Create GCP SA, bind to K8s SA, and tell Helm to use that annotation.
}

# Cert Manager
module "cert_manager_wi" {
  source  = "terraform-google-modules/iam/google//modules/workload_identity"
  version = "~> 8.2"

  name                            = "cert-manager-wi"
  project_id                      = var.project_id
  roles                           = ["roles/dns.admin"] # Required for DNS01 challenge if used
  gcp_sa_name                     = "cert-manager-sa"
  k8s_sa_name                     = "cert-manager"
  namespace                       = "cert-manager"
  annotate_k8s_sa                 = false
}

################################################################################
# Helm Releases
################################################################################

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.20.0"
  namespace  = "kube-system"

  set {
    name  = "provider"
    value = "google"
  }
  
  set {
    name  = "google.project"
    value = var.project_id
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = module.external_dns_wi.gcp_service_account_email
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }

  set {
    name  = "policy"
    value = "sync"
  }

  depends_on = [module.gke]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.19.2"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = module.cert_manager_wi.gcp_service_account_email
  }

  depends_on = [module.gke]
}
