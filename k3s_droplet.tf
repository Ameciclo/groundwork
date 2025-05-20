resource "digitalocean_droplet" "k3s" {
  name     = "ameciclo-k3s"
  region   = var.region
  size     = var.droplet_size
  image    = "ubuntu-24-04-x64"
  ipv6     = true
  vpc_uuid = digitalocean_vpc.ameciclo_vpc.id

  ssh_keys = [data.digitalocean_ssh_key.default.fingerprint]

  # Add tags for identification
  tags = ["k3s", "rancher"]
}

# Output the IP address for easy access
output "k3s_droplet_ip" {
  value = digitalocean_droplet.k3s.ipv4_address
}
