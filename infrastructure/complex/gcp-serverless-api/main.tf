provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  name_prefix = "serverless-demo"
}

################################################################################
# Firestore (Native Mode)
################################################################################

resource "google_project_service" "firestore" {
  project = var.project_id
  service = "firestore.googleapis.com"
  disable_on_destroy = false
}

resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
  
  depends_on = [google_project_service.firestore]
}

################################################################################
# Cloud Function (Gen 2)
################################################################################

# Bucket for function source
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-function-source"
  location = var.region
  uniform_bucket_level_access = true
}

# Archive source
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/function.zip"
}

# Upload source
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path
}

# Cloud Function
resource "google_cloudfunctions2_function" "function" {
  name        = "${local.name_prefix}-function"
  location    = var.region
  description = "Serverless API Handler"

  build_config {
    runtime     = "python311"
    entry_point = "hello_http" # Name of function in main.py
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

# IAM logic: Allow unauthorized access for this demo (public API)
resource "google_cloud_run_service_iam_member" "member" {
  location = google_cloudfunctions2_function.function.location
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

################################################################################
# API Gateway
################################################################################

resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = "${local.name_prefix}-api"
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider      = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id_prefix = "api-cfg"

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = base64encode(templatefile("${path.module}/openapi_spec.yaml", {
        function_uri = google_cloudfunctions2_function.function.service_config[0].uri
      }))
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "gw" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_cfg.id
  gateway_id = "${local.name_prefix}-gateway"
  region     = var.region
}
