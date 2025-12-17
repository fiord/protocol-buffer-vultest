# GCE Terraform Deployment (Minimal)

This Terraform config deploys the local Flask app to a single, minimal GCE VM and starts it with gunicorn on port 5000. Ingress is restricted to the CIDRs you configure.

## Prerequisites
- Terraform >= 1.5
- gcloud SDK installed and authenticated
- GCP project with Compute Engine API enabled
- SSH keypair for provisioning (e.g., ed25519)

Authenticate for Terraform:

```bash
# Use Application Default Credentials for the Google provider
gcloud auth application-default login
```

Enable Compute API (once per project):

```bash
gcloud services enable compute.googleapis.com --project YOUR_PROJECT_ID
```

Generate SSH key (if you don't have one yet):

```bash
ssh-keygen -t ed25519 -C yourname
```

Start ssh-agent and add your key (you will be prompted for the passphrase if the key is protected):

```bash
eval "$(ssh-agent -s)"
ssh-add /home/you/.ssh/id_ed25519
```

## Files
- main.tf – GCE VM, firewall, and provisioners
- variables.tf – input variables
- outputs.tf – public IP and app URL

## Usage
Run Terraform from the terraform/ directory so the packager zips the app from the parent folder.

1) Create terraform.tfvars (example):

```hcl
project_id           = "your-gcp-project-id"
region               = "us-central1"
zone                 = "us-central1-a"
instance_name        = "protobuf-app"
machine_type         = "e2-micro"
disk_size_gb         = 10

# Restrict to your public IP
allowed_cidrs        = ["203.0.113.10/32"]

# SSH user and keys
ssh_username         = "yourname"
ssh_public_key       = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... yourname"
ssh_private_key_path = "/home/you/.ssh/id_ed25519"
```

2) Init, plan, and apply:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

3) Output will show IP and URL:

```bash
Apply complete! Resources: X added, 0 changed, 0 destroyed.

Outputs:
app_url     = http://203.0.113.20:5000/
instance_ip = 203.0.113.20
```

4) Test the app:

```bash
curl http://$(terraform output -raw instance_ip):5000/
```

## Notes
- The VM is tagged and firewalled to only allow SSH and TCP/5000 from allowed_cidrs.
- The app runs under systemd as protobuf-app using gunicorn: app:app on port 5000.
- Instance defaults to e2-micro, 10GB pd-standard. Adjust via variables if needed.
- To tear down:

```bash
terraform destroy -auto-approve
```

## Troubleshooting
- If provisioners fail to SSH, verify allowed_cidrs includes your current public IP and your SSH key values are correct.
- Check service status on the VM:

```bash
ssh -i /home/you/.ssh/id_ed25519 yourname@$(terraform output -raw instance_ip)
sudo systemctl status protobuf-app -l
journalctl -u protobuf-app -e
```
