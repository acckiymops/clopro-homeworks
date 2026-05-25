resource "yandex_compute_instance_group" "lamp-ig" {
  name                = "lamp-ig"
  folder_id           = var.folder_id
  service_account_id  = var.service_account_id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v3"
    resources {
      memory        = 2
      cores         = 2
      core_fraction = 20
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 10
        type     = "network-hdd"
      }
    }
    network_interface {
      network_id = yandex_vpc_network.my_network.id
      subnet_ids = [yandex_vpc_subnet.public_subnet.id]
      nat        = false
    }
    metadata = {
      serial-port-enable = 1
      ssh-keys           = "ubuntu:${var.ssh_key}"
      user-data = templatefile("${path.module}/user_data.sh", {
        image_url = "https://storage.yandexcloud.net/${yandex_storage_bucket.my_bucket.id}/${yandex_storage_object.netology_logo.key}"
      })
    }
  }

  health_check {
    interval = 30
    timeout  = 10
    http_options {
      port = 80
      path = "/health"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable  = 1
    max_creating     = 1
    max_expansion    = 1
    max_deleting     = 1
    startup_duration = 30
    strategy         = "proactive"
  }

depends_on = [
    yandex_vpc_subnet.public_subnet
  ]
}

