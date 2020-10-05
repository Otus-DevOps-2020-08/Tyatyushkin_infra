variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable subnet_id {
  description = "Subnet"
}
variable app_disk_image {
  description = "disk image for reddit app"
  default = "reddit-app-base"
}
variable db_ip {
  description = "database IP"
}
variable private_key_path {
  description = "path to private key"
}
variable prov {
  description = "using prov"
}
