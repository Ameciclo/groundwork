resource "digitalocean_vpc" "ameciclo_vpc" {
  name     = var.vpc_name
  region   = var.region
  ip_range = var.vpc_ip_range
}
