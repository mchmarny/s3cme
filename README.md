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

1. Use this template to create a new repo (green button)
1. Clone the new repo locally and navigate into it
1. Run Terraform init
```shell
terraform -chdir=./setup init
```
1. Apply the Terraform configuration
```shell
terraform -chdir=./setup apply
```
1. When promoted, provide:
   * `project_id` - GCP project ID
   * `location` - GCP region
   * `git_repo` - Your qualified name of your repo (e.g. `username/repo`)
   * `name` - your application name (e.g. the repo portion from `git_repo`)
1. Update following in `conf` job in `.github/workflows/on-tag.yaml` file to the values output by Terraform
   * `IMG_NAME`
   * `KMS_KEY`
   * `PROVIDER_ID`
   * `REG_URI`
   * `SA_EMAIL`
1. Update Go and CUE policy file references to your own repo:
   * `./go.mod:module`
   * `./cmd/server/main.go`
   * `./policy/provenance.cue`
1. Write some code, PR and tag as needed ;) 

## Disclaimer

This is my personal project and it does not represent my employer. While I do my best to ensure that everything works, I take no responsibility for issues caused by this code.
