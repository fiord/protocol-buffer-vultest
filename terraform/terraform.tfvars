project_id           = "fiord-220408"
region               = "us-central1"
zone                 = "us-central1-a"
instance_name        = "protobuf-app"
machine_type         = "e2-micro"
disk_size_gb         = 10

# Restrict to your public IP
allowed_cidrs        = ["0.0.0.0/0"]

# SSH user and keys
ssh_username         = "fiord@fiord-desktop"
ssh_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCw8NXj2Pl5iKWy8j21vcJpkStvTUqmJ9B9c0nd1ecwE50k7wbDmLVT4Y3DRTAUzVVfJdBIYEkE8BL7U4qIyFUPaMo8Sm39CzcO5hFqwfAwzNK4e03PTgumyI68yWh2F99by/WnfHJWp5SUqfWU6paZ8zp16vmfgm/GUsHTyY2CDufmSi2BSHxkZZ2nojRxmIbwHK312ajPFGiKvdGwDgg1RhBTMAoLRVbk1PMqFbPWUh+WqW/vYAwT3YAS0Xzuzo/foOh6FYJI9n3H7vEBjMnQFeZqmvXb0lvbezCSgh8fUGCB1ttFPMTEsD+bT9pvWvyabbmP4RK4+4h0ytjUqVMRAXn1YDA9khVovG1ZsYN7b/TXDPtS8VUucLjblbGIotbIL5G1FhqWQxdmmU/mwj8le17UWUBmNasmSo9U3UdiED2UwwW+LM3W5elZE6XiISmL1tloqaXwg3+0Cz7UxqUVKP9olql1afrF4v6oNBdfyPJBaAd3Q9XTUiT+Pz5uQsM= fiord@fiord-desktop"
ssh_private_key_path = "/home/fiord/.ssh/google_compute_engine"