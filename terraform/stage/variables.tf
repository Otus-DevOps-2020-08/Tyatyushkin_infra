variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  default     = "ru-central1-a"
}
variable region_id {
  description = "region"
  default     = "ru-central1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable image_id {
  description = "Disk image"
}
variable subnet_id {
  description = "Subnet"
}
variable service_account_key_file {
  description = "key .json"
}
variable private_key_path {
  description = "path to private key"
}
variable instances {
  description = "count instances"
  default     = 1
}
variable app_disk_image {
  description = "disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "disk image for mongodb"
  default     = "reddit-db-base"
}
variable prov {
  description = "using provisioner"
  default = true
}
