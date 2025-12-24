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

## Test manually (on an instance)

SSH to the instance and run the userdata locally for quick testing (requires root):

```bash
sudo bash /path/to/userdata.sh
# or
sudo bash /path/to/userdata1.sh
```

Then verify Apache is running and view the page:

```bash
sudo systemctl status apache2
curl -s http://localhost/ | head -n 40
```

## Recommended improvements

- Add an IAM instance profile with an IAM policy that grants `s3:GetObject` for the bucket you use. This allows the instance to download images without embedding credentials.
- Render the S3 bucket name from Terraform (a variable) into the instance userdata so you can control it from Terraform. For example, add a `variable "userdata_bucket" {}` and pass it to the `user_data` template.
- Add Terraform outputs for instance public IP so testing is simpler: e.g. `output "instance_public_ip" { value = aws_instance.web.public_ip }
`

## Troubleshooting

- If the image doesn't appear, check `/tmp/aws_s3_copy.log` or `/tmp/aws_s3_copy1.log` on the instance for AWS CLI errors.
- If metadata calls fail (169.254.169.254), ensure the script runs on an EC2 instance (the metadata service is only available on cloud instances).

---

If you want, I can:
- Modify the Terraform files to pass a `user_data` template that includes a `userdata_bucket` variable, and add an `output` with the instance public IP.
- Create a minimal `terraform.tfvars` example and an IAM instance profile and policy template for S3 read access.

Which of those would you like me to do next?