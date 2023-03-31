
# Service Account under which the Cloud Run services will run
resource "google_service_account" "runner_service_account" {
  account_id   = "${var.name}-runner"
  display_name = "${var.name}-runner"
}

# App Cloud Run service 
resource "google_cloud_run_service" "default" {
  for_each = toset(var.regions)

  name                       = "${var.name}--${each.value}"
  location                   = each.value
  project                    = var.project_id
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = var.image
        ports {
          name           = "http1"
          container_port = 8080
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        env {
          name  = "ADDRESS"
          value = ":8080"
        }
        env {
          name  = "LOG_LEVEL"
          value = var.log_level
        }
      }

      container_concurrency = 80
      timeout_seconds       = 120
      service_account_name  = google_service_account.runner_service_account.email
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "10"
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/client-name" = "terraform"
      "run.googleapis.com/ingress"     = "internal-and-cloud-load-balancing"
      # all, internal, internal-and-cloud-load-balancing
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public-access" {
  for_each = toset(var.regions)

  location = google_cloud_run_service.default[each.key].location
  project  = google_cloud_run_service.default[each.key].project
  service  = google_cloud_run_service.default[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


