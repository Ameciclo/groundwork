resource "digitalocean_droplet" "web" {
  count    = 1 # Adjust count for multiple droplets
  name     = "ameciclo-${count.index + 1}"
  region   = var.region
  size     = var.droplet_size
  image    = "ubuntu-24-04-x64"
  ipv6     = true
  vpc_uuid = digitalocean_vpc.ameciclo_vpc.id

  ssh_keys = [data.digitalocean_ssh_key.default.fingerprint]
}
