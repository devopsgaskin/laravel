# Define your provider (DigitalOcean)
provider "digitalocean" {
  token = "YOUR_DO_API_TOKEN"
}

# Define a DigitalOcean SSH key (you should create this key beforehand)
resource "digitalocean_ssh_key" "alparslan_ssh_key" {
  name       = "alparslan-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Define a DigitalOcean droplet (VM)
resource "digitalocean_droplet" "alparslan_vm" {
  name   = "alparslan-vm"
  region = "nyc3"
  size   = "s-2vcpu-2gb"
  image  = "ubuntu-20-04-x64"
  ssh_keys = [digitalocean_ssh_key.alparslan_ssh_key.fingerprint]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = self.ipv4_address
  }
}

# Define a DigitalOcean Load Balancer
resource "digitalocean_loadbalancer" "alparslan_lb" {
  name       = "alparslan-lb"
  region     = "nyc3"
  algorithm  = "round_robin"
  droplet_ids = [digitalocean_droplet.alparslan_vm.id]
}

# Define the startup script for the VM
resource "digitalocean_droplet" "alparslan_vm" {
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF
}

# Provision the Load Balancer with SSL certificate
resource "digitalocean_certificate" "alparslan_certificate" {
  name       = "alparslan-certificate"
  private_key = file("path/to/your/private/key.pem")
  certificate = file("path/to/your/certificate.pem")
}

resource "digitalocean_loadbalancer_https" "alparslan_lb_https" {
  loadbalancer_id = digitalocean_loadbalancer.alparslan_lb.id
  certificate_id = digitalocean_certificate.alparslan_certificate.id
  default = true
}

# Define the firewall to allow incoming traffic (adjust rules as needed)
resource "digitalocean_firewall" "alparslan_firewall" {
  name = "alparslan-firewall"

  inbound_rule {
    protocol           = "tcp"
    port_range         = "80"
    source_addresses  = ["0.0.0.0/0"]
  }
  
  inbound_rule {
    protocol           = "tcp"
    port_range         = "443"
    source_addresses  = ["0.0.0.0/0"]
  }
  
  # Add more rules as needed, like SSH or specific application ports.
}

# Output the Load Balancer IP
output "load_balancer_ip" {
  value = digitalocean_loadbalancer.alparslan_lb.ip
}