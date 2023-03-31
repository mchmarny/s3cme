# List of cloud run services created in terraform apply 

output "cloud_run_services" {
  value = toset([
    for s in google_cloud_run_service.default : s.status[0].url
  ])
}

output "external_ip" {
  value       = module.lb-http.external_ip
  description = "Resulting IP on LB that is routing traffic to Cloud Run services."
}

output "external_url" {
  value       = "https://${var.domain}/"
  description = "Resulting URL on LB that is routing traffic to Cloud Run services."
}