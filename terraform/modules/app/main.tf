resource "yandex_compute_instance" "app" {
  name = "reddit-app"

  labels = {
    tags = "reddit-app"
  }
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }

  metadata = {
  ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

resource "null_resource" "app" {
  count = var.prov ? 1 : 0
  triggers = {
    cluster_instance_ids = yandex_compute_instance.app.id
  }
 connection {
    type        = "ssh"
    host        = yandex_compute_instance.app.network_interface[0].nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }
 provisioner "file" {
    content     = templatefile("${path.module}/files/puma.service.tmpl", { db_ip = var.db_ip})
    destination = "/tmp/puma.service"
  }

 provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
}
