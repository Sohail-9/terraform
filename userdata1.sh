#!/bin/bash
set -e

# Install required packages
apt-get update -y
apt-get install -y apache2 awscli curl

# Metadata and host info
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || echo unknown)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 || echo unknown)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo unavailable)
HOSTNAME_FULL=$(hostname -f 2>/dev/null || hostname)
NOW=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# S3 bucket (override with USERDATA_BUCKET env var)
BUCKET=${USERDATA_BUCKET:-myterraformprojectbucket2023}

mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Try downloading an image from S3 (non-fatal)
if aws s3 cp "s3://${BUCKET}/project.webp" /var/www/html/project.png --acl public-read 2>/tmp/aws_s3_copy1.log; then
  IMAGE_PRESENT=1
else
  IMAGE_PRESENT=0
fi

if [ "$IMAGE_PRESENT" -eq 1 ]; then
  IMG_TAG="<img src=\"/project.png\" alt=\"Project image\" style=\"max-width:100%;height:auto;border-radius:8px;box-shadow:0 6px 18px rgba(0,0,0,0.12);\">"
else
  IMG_TAG=""
fi

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Terraform Portfolio</title>
  <style>
    :root{--accent:#34d399;--muted:#9ca3af}
    body{margin:0;font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial;color:#e6eef8;background:#071024;display:flex;align-items:center;justify-content:center;min-height:100vh}
    .card{max-width:900px;width:95%;background:rgba(255,255,255,0.02);padding:24px;border-radius:10px}
    h1{margin:0;color:var(--accent);animation:colorChange 3s infinite}
    @keyframes colorChange{0%{color:#34d399}50%{color:#60a5fa}100%{color:#a78bfa}}
    .meta{color:var(--muted);margin-top:6px}
    .grid{display:grid;grid-template-columns:1fr 300px;gap:16px;margin-top:14px}
    @media(max-width:800px){.grid{grid-template-columns:1fr}}
  </style>
</head>
<body>
  <div class="card">
    <h1>Terraform Project — Server 1</h1>
    <div class="meta">Updated: ${NOW}</div>
    <div class="grid">
      <div>
        <p>Instance details:</p>
        <ul>
          <li><strong>Instance ID:</strong> ${INSTANCE_ID}</li>
          <li><strong>Hostname:</strong> ${HOSTNAME_FULL}</li>
          <li><strong>Private IP:</strong> ${PRIVATE_IP}</li>
          <li><strong>Public IP:</strong> ${PUBLIC_IP}</li>
        </ul>
        <p>Welcome to Sohail's Channel — customize this page as you wish.</p>
      </div>
      <div>
        ${IMG_TAG}
      </div>
    </div>
  </div>
</body>
</html>
EOF

# Start and enable apache
systemctl restart apache2 || systemctl start apache2
systemctl enable apache2

echo "userdata1: completed at $(date -u +'%Y-%m-%dT%H:%M:%SZ')"