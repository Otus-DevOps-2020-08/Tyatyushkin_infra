terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "tyatyushkin"
    region   = "ru-central1"
    key      = "stage/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
