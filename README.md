# s3cme

Sample Go app repo with test (on push) and release (on tag) pipelines optimized for software supply chain security (S3C). Includes Terraform setup for [OpenID Connect](https://openid.net/connect/) (IODC) in GCP with Artifact Registry, and KMS service configuration.

What's included in the PR qualification (on push), and release (on tag) pipelines:

* On push:
  * Semantic code analysis using CodeQL
  * Source vulnerability scan using Trivy
  * Sarif-formatted report for repo alerts
* On tag:
  * Same test as on push
  * Image build and registry push using ko with with SBOM generation 
  * Image vulnerability scan using Trivy with max severity checks
  * Image signing using KMS key and attestation using cosign
  * SLSA provenance generation for GitHub workflow
  * SLSA provenance verification using cosign and CUE policy

## Usage 

1. 

## Disclaimer

This is my personal project and it does not represent my employer. While I do my best to ensure that everything works, I take no responsibility for issues caused by this code.
