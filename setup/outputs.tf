# Description: Outputs for the deployment

output "REG_URI" {
  value       = "${google_artifact_registry_repository.registry.location}-docker.pkg.dev"
  description = "Artifact Registry location."
}

output "IMAGE_URI" {
  value       = "${data.google_project.project.name}/${google_artifact_registry_repository.registry.name}"
  description = "Artifact Registry location."
}

output "IMAGE_NAME" {
  value       = google_artifact_registry_repository.registry.name
  description = "Artifact Registry location."
}

output "SA_EMAIL" {
  value       = google_service_account.github_actions_user.email
  description = "Service account to use in GitHub Action for federated auth."
}

output "PROVIDER_ID" {
  value       = google_iam_workload_identity_pool_provider.github_provider.name
  description = "Provider ID to use in Auth action for GCP in GitHub."
}

output "KMS_KEY" {
  value       = "gcpkms://${data.google_kms_crypto_key_version.version.name}"
  description = "Cosign-formated URI to the signing key."
}
