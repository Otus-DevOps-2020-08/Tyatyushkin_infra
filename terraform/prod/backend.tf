terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "tyatyushkin"
    region     = "ru-central1"
    key        = "prod/terraform.tfstate"
    #access_key = "pMDsgiqTsbXxC0KCnMxX"
    #secret_key = "Xti024Ktp_3SOqcaPvvmDtChgmEmP9ODH7YqnjVu"

    skip_region_validation      = true
    skip_credentials_validation = true
   }
}
