# Description: This file contains the provider configuration for the project

# Configure the Google Cloud provider
terraform {
  required_version = ">= 1.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.4"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.4"
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
}

# Configure the beta version of Google Cloud provider
provider "google-beta" {
  project = var.project_id
}