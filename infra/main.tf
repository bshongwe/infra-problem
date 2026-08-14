terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.digitalocean_token
}

# Get the latest Ubuntu 22.04 image
data "digitalocean_image" "ubuntu" {
  slug = "ubuntu-22-04-x64"
}

# Get the SSH key for the current user (optional)
data "digitalocean_ssh_key" "current_user" {
  count = var.ssh_key_name != "" ? 1 : 0
  name  = var.ssh_key_name
}

# Create a firewall for the droplet
resource "digitalocean_firewall" "newsfeed_firewall" {
  name = "newsfeed-firewall"

  # Allow SSH from specific IPs
  dynamic "inbound_rule" {
    for_each = var.allowed_ssh_cidrs
    content {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = [inbound_rule.value]
    }
  }

  # Allow HTTP traffic
  inbound_rule {
    protocol         = "tcp"
    port_range       = tostring(var.frontend_port)
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = tostring(var.static_assets_port)
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol         = "udp"
    port_range       = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol         = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  droplet_ids = [digitalocean_droplet.newsfeed.id]
}

# Create the droplet
resource "digitalocean_droplet" "newsfeed" {
  name  = "newsfeed-app"
  size  = var.droplet_size
  image = data.digitalocean_image.ubuntu.id
  region = var.droplet_region

  # SSH key for access
  ssh_keys = length(data.digitalocean_ssh_key.current_user) > 0 ? [
    data.digitalocean_ssh_key.current_user[0].id
  ] : []

  # Cloud-init script to set up the environment
  user_data = templatefile("${path.module}/user-data.sh", {
    github_repo       = var.github_repo
    github_branch     = var.github_branch
    frontend_port     = var.frontend_port
    newsfeed_port     = var.newsfeed_port
    quotes_port       = var.quotes_port
    static_assets_port = var.static_assets_port
    newsfeed_token    = var.newsfeed_token
  })

  tags = ["newsfeed", "microservices"]
}

# Output the droplet's IP address
output "droplet_ip" {
  description = "The public IP address of the droplet"
  value       = digitalocean_droplet.newsfeed.ipv4_address
}

# Output the front-end URL
output "front_end_url" {
  description = "The URL to access the front-end application"
  value       = "http://${digitalocean_droplet.newsfeed.ipv4_address}:${var.frontend_port}"
}

# Output the SSH connection command
output "ssh_command" {
  description = "SSH command to connect to the droplet"
  value       = var.ssh_key_name != "" ? "ssh root@${digitalocean_droplet.newsfeed.ipv4_address}" : "SSH access requires an SSH key"
}
