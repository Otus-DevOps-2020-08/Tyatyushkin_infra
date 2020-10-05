variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable subnet_id {
  description = "Subnet"
}
variable db_disk_image {
  description = "disk image for mongodb"
  default = "reddit-db-base"
}
variable private_key_path {
  description = "path to private key"
}
variable prov {
  description = "using prov"
}
