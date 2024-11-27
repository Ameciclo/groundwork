resource "digitalocean_spaces_bucket" "s3_space" {
  name   = var.s3_space_name
  region = var.region
}
