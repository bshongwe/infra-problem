variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "droplet_size" {
  description = "The size of the droplet (e.g., s-2vcpu-4gb)"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "droplet_region" {
  description = "The region for the droplet (e.g., nyc3, sfo2, lon1)"
  type        = string
  default     = "nyc3"
}

variable "ssh_key_name" {
  description = "Name of the SSH key to use for droplet access (leave empty for password auth)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the droplet"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Restrict this in production!
}

variable "github_repo" {
  description = "GitHub repository URL for the application"
  type        = string
  default     = "https://github.com/melio-consulting/infra-problem.git"
}

variable "github_branch" {
  description = "Git branch to deploy"
  type        = string
  default     = "devops-assessment"
}

variable "frontend_port" {
  description = "Port for the front-end service"
  type        = number
  default     = 8000
}

variable "newsfeed_port" {
  description = "Port for the newsfeed service"
  type        = number
  default     = 8081
}

variable "quotes_port" {
  description = "Port for the quotes service"
  type        = number
  default     = 8080
}

variable "static_assets_port" {
  description = "Port for the static assets service"
  type        = number
  default     = 8001
}

variable "newsfeed_token" {
  description = "Authentication token for the newsfeed service"
  type        = string
  default     = "T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX"
  sensitive   = true
}
