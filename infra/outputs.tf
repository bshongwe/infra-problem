output "droplet_ip" {
  description = "The public IP address of the droplet"
  value       = digitalocean_droplet.newsfeed.ipv4_address
}

output "front_end_url" {
  description = "The URL to access the front-end application"
  value       = "http://${digitalocean_droplet.newsfeed.ipv4_address}:${var.frontend_port}"
}

output "ssh_command" {
  description = "SSH command to connect to the droplet"
  value       = var.ssh_key_name != "" ? "ssh root@${digitalocean_droplet.newsfeed.ipv4_address}" : "SSH access requires an SSH key"
}
