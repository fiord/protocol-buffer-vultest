variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Compute Engine instance name"
  type        = string
  default     = "protobuf-app"
}

variable "machine_type" {
  description = "GCE machine type (minimal perf)"
  type        = string
  default     = "e2-micro"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access SSH and the app (e.g., your public IP/32)"
  type        = list(string)
}

variable "ssh_username" {
  description = "Linux username to be created/used for SSH access"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content for the user (as a single line)"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local path to the SSH private key (used by Terraform provisioners)"
  type        = string
  sensitive   = true
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    app = "protobuf-app"
    env = "dev"
  }
}
