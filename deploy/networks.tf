# Serverless Network Endpoint Groups (NEGs) for HTTPS LB to CLoud Run services
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "6.2.0"

  project = var.project_id
  name    = var.name

  create_address = false
  address        = google_compute_global_address.http_lb_address.address

  ssl                             = true
  managed_ssl_certificate_domains = ["${var.domain}"]
  https_redirect                  = true

  backends = {
    default = {
      description             = null
      enable_cdn              = false
      security_policy         = google_compute_security_policy.policy.name
      custom_request_headers  = null
      custom_response_headers = null

      groups = [
        for neg in google_compute_region_network_endpoint_group.serverless_neg :
        {
          group = neg.id
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

    }
  }

  depends_on = [
    google_project_service.default["compute.googleapis.com"],
    google_compute_global_address.http_lb_address,
  ]
}

# Region network endpoint group for Cloud Run sercice in that region
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each = toset(var.regions)

  name                  = "${var.name}--neg--${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.default[each.key].location

  cloud_run {
    service = google_cloud_run_service.default[each.key].name
  }
}