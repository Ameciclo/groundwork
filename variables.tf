variable "digitalocean_token" {}
variable "digitalocean_spaces_access_key" {}
variable "digitalocean_spaces_secret_key" {}
variable "region" {
  default = "nyc3"
}
variable "droplet_size" {
  default = "s-2vcpu-4gb-amd"
}
variable "postgresql_name" {
  default = "ameciclo-postgres-db"
}
variable "s3_space_name" {
  default = "ameciclo-space"
}
variable "vpc_name" {
  default = "ameciclo-vpc"
}
variable "vpc_ip_range" {
  default = "10.10.0.0/16"
}
