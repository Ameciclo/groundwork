resource "digitalocean_database_cluster" "postgresql" {
  name                 = var.postgresql_name
  engine               = "pg"
  version              = "16"
  region               = var.region
  size                 = "amd-1-1-25-dd"
  node_count           = 1
  private_network_uuid = digitalocean_vpc.ameciclo_vpc.id
}
