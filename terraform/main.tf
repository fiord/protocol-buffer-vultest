terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

# Package the application (excluding terraform and other non-runtime dirs)
data "archive_file" "app_zip" {
  type        = "zip"
  source_dir  = abspath("${path.module}/..")
  output_path = "${path.module}/app.zip"
  excludes = [
    ".git/**",
    ".terraform/**",
    "terraform/**",
    "outputs/**",
    "deliverables/**",
    "**/__pycache__/**",
    "*.tfstate*",
    "*.zip"
  ]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.instance_name}-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_cidrs
  target_tags   = ["protobuf-app"]
}

resource "google_compute_firewall" "app_ingress" {
  name    = "${var.instance_name}-app"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_ranges = var.allowed_cidrs
  target_tags   = ["protobuf-app"]
}

resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["protobuf-app"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = var.disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  labels = var.labels

  metadata = {
    # Add your SSH public key so Terraform provisioners can connect
    ssh-keys = "${var.ssh_username}:${var.ssh_public_key}"
  }

  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # Upload packaged app archive to the VM
  provisioner "file" {
    source      = data.archive_file.app_zip.output_path
    destination = "/tmp/app.zip"

    connection {
      type        = "ssh"
      host        = self.network_interface[0].access_config[0].nat_ip
      user        = var.ssh_username
      agent       = true
      timeout     = "5m"
    }
  }

  # Install deps, unpack, and run the app under systemd with gunicorn
  provisioner "remote-exec" {
    inline = [
      "set -eux",
      "sudo apt-get update -y",
      "sudo apt-get install -y python3-pip python3-venv unzip rsync",
      "sudo mkdir -p /opt/protobuf-app-src /opt/protobuf-app",
      "sudo unzip -o /tmp/app.zip -d /opt/protobuf-app-src",
      "sudo rsync -a --delete /opt/protobuf-app-src/ /opt/protobuf-app/",
      "sudo chown -R ${var.ssh_username}:${var.ssh_username} /opt/protobuf-app",
      "cd /opt/protobuf-app",
      "python3 -m venv venv",
      "/opt/protobuf-app/venv/bin/pip install --upgrade pip",
      "/opt/protobuf-app/venv/bin/pip install -r requirements.txt",
      "/opt/protobuf-app/venv/bin/pip install gunicorn",
      "sudo bash -c 'cat > /etc/systemd/system/protobuf-app.service <<EOF\n[Unit]\nDescription=Protocol Buffer Flask App\nAfter=network-online.target\nWants=network-online.target\n\n[Service]\nType=simple\nUser=${var.ssh_username}\nWorkingDirectory=/opt/protobuf-app\nExecStart=/opt/protobuf-app/venv/bin/gunicorn -w 2 -b 0.0.0.0:5000 app:app\nRestart=always\nRestartSec=5\n\n[Install]\nWantedBy=multi-user.target\nEOF'",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable --now protobuf-app",
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[0].access_config[0].nat_ip
      user        = var.ssh_username
      agent       = true
      timeout     = "10m"
    }
  }

  depends_on = [
    google_compute_firewall.allow_ssh,
    google_compute_firewall.app_ingress,
  ]
}
