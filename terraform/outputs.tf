output "instance_ip" {
  description = "External IP of the GCE instance"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "app_url" {
  description = "URL to access the Flask app"
  value       = "http://${google_compute_instance.vm.network_interface[0].access_config[0].nat_ip}:5000/"
}
