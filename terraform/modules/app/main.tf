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
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

data "yandex_compute_instance" "db_instance" {
  name = "reddit-db"
}

resource "null_resource" "app" {
  count = var.deploy ? 1 : 0

  connection {
    type        = "ssh"
    host        = yandex_compute_instance.app.network_interface[0].nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/puma.service.tmpl", { db_ip = data.yandex_compute_instance.db_instance.network_interface.0.ip_address })
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
}
