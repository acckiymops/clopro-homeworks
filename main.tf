resource "yandex_vpc_network" "my_network" {
  name = "netology"
}

resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my_network.id
}

resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my_network.id
  route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_vpc_route_table" "private_rt" {
  name       = "private_rt"
  network_id = yandex_vpc_network.my_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance.network_interface[0].ip_address
  }
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_id
}

resource "yandex_compute_instance" "nat_instance" {
  name                      = "nat_instance"
  hostname                  = "nat-vm"
  platform_id               = "standard-v3"
  zone                      = var.default_zone
  allow_stopping_for_update = true
  resources {
    cores         = var.vm_resources.vm.cores
    memory        = var.vm_resources.vm.memory
    core_fraction = var.vm_resources.vm.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      type     = var.vm_resources.vm.disk_type
      size     = var.vm_resources.vm.disk_size
    }
  }
  scheduling_policy {
    preemptible = var.vm_resources.vm.preemptible
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.public_subnet.id
    ip_address = "192.168.10.254"
    nat        = false
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.ssh_key}"
  }
}

resource "yandex_compute_instance" "public_vm" {
  name                      = "public_vm"
  hostname                  = "public-vm"
  platform_id               = "standard-v3"
  zone                      = var.default_zone
  allow_stopping_for_update = true
  resources {
    cores         = var.vm_resources.vm.cores
    memory        = var.vm_resources.vm.memory
    core_fraction = var.vm_resources.vm.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = var.vm_resources.vm.disk_type
      size     = var.vm_resources.vm.disk_size
    }
  }
  scheduling_policy {
    preemptible = var.vm_resources.vm.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet.id
    nat       = false
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.ssh_key}"
  }
}

resource "yandex_compute_instance" "private_vm" {
  name                      = "private_vm"
  hostname                  = "private-vm"
  platform_id               = "standard-v3"
  zone                      = var.default_zone
  allow_stopping_for_update = true
  resources {
    cores         = var.vm_resources.vm.cores
    memory        = var.vm_resources.vm.memory
    core_fraction = var.vm_resources.vm.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = var.vm_resources.vm.disk_type
      size     = var.vm_resources.vm.disk_size
    }
  }
  scheduling_policy {
    preemptible = var.vm_resources.vm.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_subnet.id
    nat       = false
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.ssh_key}"
  }
}