# EKS Migration — Production-ready Terraform scaffold

This repository contains a production-minded Terraform scaffold for migrating an on-prem Docker Swarm workload to Amazon EKS.

Key practices included:

- Remote state (S3 + DynamoDB locks) — see `backend.tf` and pre-create S3 bucket + DynamoDB table before `terraform init`.
- Infrastructure as code using `terraform-aws-modules/eks/aws` for a managed EKS cluster and managed node groups.
- OIDC provider / IRSA support enabled to follow least-privilege patterns for Kubernetes service accounts.
- Clear variables and an example `terraform.tfvars.example` for environment-specific values.
- Example Kubernetes manifests in `k8s/examples/` to help migrate services from Docker Swarm to Kubernetes.
- `Makefile` with helper commands for common Terraform operations.

Recommended workflow (high level):

1. Prepare remote state
   - Create the S3 bucket and DynamoDB table used by the `backend.tf` backend.

2. Customize variables
   - Copy `terraform.tfvars.example` to `terraform.tfvars` and update values.

3. Initialize and plan

```bash
make init
make plan
```

4. Apply

```bash
make apply
```

5. Configure kubectl

```bash
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

Migration checklist for production DevOps teams

- CI/CD
  - Use pipelines (GitHub Actions, GitLab CI, CircleCI, etc.) to run `terraform fmt`, `terraform validate`, `terraform plan` and store plan artifacts.
  - Gate `terraform apply` behind approvals for non-dev environments.

- Secrets
  - Do NOT put secrets in Terraform. Use AWS Secrets Manager, SSM Parameter Store, or external secrets operator for Kubernetes.

- Images / Registry
  - Build images in CI, push to ECR, and update Kubernetes manifests to reference ECR images.
  - Use a pipeline to deploy manifests or Helm charts to the EKS cluster.

- IAM and Security
  - Use IRSA (IAM Roles for Service Accounts) to grant fine-grained AWS permissions to pods.
  - Limit node IAM permissions; prefer EKS-managed node role with minimal policies.

- Observability
  - Install cluster monitoring (Prometheus/Grafana), logging (Fluent Bit -> CloudWatch/Elasticsearch), and tracing as needed.

- Networking
  - Consider private EKS clusters (no public endpoint) and use VPC endpoints for AWS APIs for security.
  - Use AWS ALB Ingress Controller or AWS Load Balancer Controller (via Helm) for HTTP/S ingress.

- Autoscaling
  - Enable Cluster Autoscaler and HorizontalPodAutoscaler for workload-driven scaling.

- Testing & DR
  - Run integration tests in a staging cluster.
  - Define disaster recovery procedures and cluster backups (etcd backup for control-plane managed by AWS, but backup persistent volumes and critical data stores).

Next steps I can implement for you (pick one):

- Add a `ci/` pipeline example (GitHub Actions) that runs `terraform fmt`/`validate`/`plan` and stores plan artifacts.
- Add an example IRSA role and Kubernetes service account + minimal policy for S3 or ECR access.
- Add Helm + manifest examples to replace your Docker Swarm stacks and a sample GitOps workflow using ArgoCD or Flux.
# Terraform Demo — Portfolio Webpage

This repository contains a small Terraform project that provisions an instance and uses userdata scripts to create a simple portfolio webpage served by Apache. The userdata scripts (`userdata.sh`, `userdata1.sh`) generate a responsive HTML page and optionally display an image downloaded from an S3 bucket.

## What this does

- Installs Apache and AWS CLI on the instance
- Fetches instance metadata (Instance ID, hostname, private/public IP) and injects into the HTML
- Attempts to download `project.webp` from an S3 bucket and save it as `/var/www/html/project.png` (optional)
- Creates a polished, responsive `index.html` in `/var/www/html`

## Files

- `main.tf`, `provider.tf`, `variables.tf` — Terraform configuration (existing in this repo)
- `userdata.sh` — Enhanced userdata script that builds the portfolio page and tries to pull an S3 image
- `userdata1.sh` — Alternate userdata script (updated to match `userdata.sh` enhancements)

## Customization

- S3 bucket: By default the userdata scripts look for `myterraformprojectbucket2023`. To change this you can either:
  - Edit the `BUCKET` value inside the userdata scripts, or
  - Export `USERDATA_BUCKET` environment variable in the provisioning mechanism that injects the userdata (or modify Terraform to render the desired bucket value into the instance userdata).

- Image: To show an image on the page, upload a file named `project.webp` to the S3 bucket. Example:

```bash
aws s3 cp project.webp s3://your-bucket-name/project.webp --acl public-read
```

Note: For the instance to fetch from S3 using the AWS CLI, the instance must have permissions (IAM instance profile) allowing `s3:GetObject`, or you must provide credentials in another secure way.

## Deploy (typical)

1. Initialize Terraform:

```bash
terraform init
```

2. (Optional) Review variables in `variables.tf` and edit `terraform.tfvars` or pass `-var` flags when running `plan`/`apply`.

3. Create an execution plan and apply:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

After Terraform finishes, find the instance public IP (from AWS console, EC2 instances list, or your Terraform outputs if present) and open `http://<public-ip>/` in a browser.

# Terraform migration: Docker Swarm -> Amazon EKS

This repository has been migrated from provisioning standalone EC2 webservers (Docker Swarm / Apache style) to provisioning an Amazon EKS cluster using the
`terraform-aws-modules/eks/aws` Terraform module.

What changed:
- `main.tf` now creates an EKS cluster (with a managed node group) and a VPC (created by the module).
- Old EC2 instances / ALB and userdata-based Apache webpage provisioning have been removed/deprecated.
- `provider.tf`, `variables.tf` and `outputs.tf` were updated to support EKS deployment.

Quick start (deploy EKS):

1. Initialize Terraform:

```bash
terraform init
```

2. (Optional) Edit variables by creating `terraform.tfvars` or pass `-var` flags. Common variables:

- `aws_region` — AWS region to deploy (default: `us-east-1`)
- `cluster_name` — EKS cluster name
- `cluster_version` — Kubernetes version (e.g. `1.28`)
- `node_instance_type` — worker node instance type (default: `t3.medium`)
- `node_desired_capacity`, `node_min_capacity`, `node_max_capacity`

3. Plan and apply:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

4. Configure kubectl (after apply completes):

```bash
aws eks update-kubeconfig --name <cluster_name> --region <aws_region>
kubectl get nodes
```

Notes and next steps:
- The module creates IAM roles, security groups and node groups for you. Review the generated resources and adjust variables to fit production needs.
- If you require node bootstrap customization, add `user_data`/`bootstrap` settings for node groups in the EKS module configuration.
- Consider enabling private cluster options, fine-grained IAM policies, and node autoscaling for production.

If you'd like, I can:
- Add an example `terraform.tfvars` with recommended values.
- Add an IAM OIDC provider and example IRSA (IAM Roles for Service Accounts) setup for fine-grained permissions.
- Create a sample Helm chart / Kubernetes manifest to replace your old Docker Swarm apps.

Tell me which of the above you'd like next.
