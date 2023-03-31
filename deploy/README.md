# deploy

This deployment bootstraps a fully functional, multi-region, deployment of `s3cme` on GCP containing:

**Cloud Run** 

Service provisioned into n-number of regions with (default: `us-west1`, `europe-west1`, `asia-east1`) running under service account with custom capacity/autoscaling strategy. This service will be accessible only via Internal and Load Balancer traffic (i.e. no external access).

**Load Balancer**

HTTPS load balancer configured with external IP and SSL certificate using Serverless NEGs for load balancer to point to Cloud Run service in each region. This service will also create Cloud DNS service with A record for custom domain.

**Other**

* Cloud Armor service with throttling and Canary CVE policies
* Service uptime and SSL cert expiration alerts
  

## Deployment

> This assumes an already published image in GCR

1. Initialize terraform

> Note, this flow uses local terraform state, make sure you do not check that into source control and consider using persistent state provider like GCS

The service deployment step uses few new Terraform modules, so start by initializing the deployment inside of the `deploy` directory:

```shell
terraform init
```

2. Apply the configuration

This deployment will prompt for a lot of variables, you can create `variables.tf` with the following entries in `deploy` folder to avoid these prompts. Edit these as necessary:

```txt
project_id     = "your-project-id"
name           = "s3cme"
domain         = "your.domain.dev"
regions        = ["us-west1", "europe-west1", "asia-east1"]
image          = "restme"
log_level      = "info"
alert_email    = "you@domain.com"
```

> Note, the domain must be something you can control DNS for as you will have to create an `A` entry to point to the `IP` in Terraform output for this step. 


```sh
terraform apply
```

The result of `apply` should be a list of Cloud Run services (URLs) for each one of the regions you deployed to, as well as the external IP and URL on the load balancer by which you can access these services. 

> Note, you will not be able to access the Cloud Run services directly as their ingress (trigger) is internal and Cloud load balancer only. 

```shell
cloud_run_services = toset([
  "https://restme--asia-east1-fr3j36toba-de.a.run.app",
  "https://restme--europe-west1-fr3j36toba-ew.a.run.app",
  "https://restme--us-west1-fr3j36toba-uw.a.run.app",
])
external_ip = "x.x.x.x"
external_url = "https://your.domain.dev/"
```

It will take a few min for the SSL certificate to be provisioned. As soon as the `apply` step completes, use the IP in `external_ip` to create an `A` record in your DNS to point to the domain in `external_url`. For example: 

Host Name: `demo` # the `your` portion of `your.domain.dev`
Type: `A`
TTL: `60`
Data: `x.x.x.x` # the actual IP returned by the above step

> Note, the SSL cert provisioning in the above action will take a few min. You can navigate to https://console.cloud.google.com/security/ccm/lbCertificates/details/$NAME-cert?project=$PROJECT

Assuming everything went OK, you should now be able to test the deployment by using `curl` to invoke the address returned by the `external_url` output

```shell
url https://your.domain.dev/
```

## Clean up

To clean up each of these deployments run the following command:

> Note, the project itself and the external IP address will not be deleted and all APIs enabled as part of these deployments will stay enabled. 

```sh
terraform destroy
```