provider "google" {
  project = var.project_id
  region  = var.region
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.project_name}-site-${random_id.bucket_suffix.hex}"
}

################################################################################
# Cloud Storage Bucket
################################################################################

module "gcs_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 12.0"

  name       = local.bucket_name
  project_id = var.project_id
  location   = var.region

  iam_members = [{
    role   = "roles/storage.objectViewer"
    member = "allUsers" # Publicly readable for static site
  }]
  
  website = {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

################################################################################
# Load Balancer with CDN
################################################################################

module "lb-http" {
  source  = "terraform-google-modules/lb-http/google"
  version = "~> 14.0"

  project = var.project_id
  name    = "${var.project_name}-lb"

  target_tags = [] # No VMs, so no tags needed

  # Configure backend bucket
  backend_buckets = {
    default-backend-bucket = {
      description = "Backend bucket for static site"
      bucket_name = module.gcs_bucket.name
      enable_cdn  = true
      cdn_policy = {
        cache_mode        = "CACHE_ALL_STATIC"
        client_ttl        = 3600
        default_ttl       = 3600
        max_ttl           = 86400
        negative_caching  = true
        serve_while_stale = 86400
      }
    }
  }
}
