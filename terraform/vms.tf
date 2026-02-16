# Считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

# Статический IP для Bastion
resource "yandex_vpc_address" "bastion_ip" {
  name = "bastion-static-ip"
  
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# Статический IP для Grafana
resource "yandex_vpc_address" "grafana_ip" {
  name = "grafana-static-ip"
  
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# Статический IP для Kibana
resource "yandex_vpc_address" "kibana_ip" {
  name = "kibana-static-ip"
  
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# Bastion host
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = var.CMCF.cores
    memory        = var.CMCF.memory
    core_fraction = var.CMCF.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_public_a.id
    nat       = true
    nat_ip_address = yandex_vpc_address.bastion_ip.external_ipv4_address[0].address
    security_group_ids = [
      yandex_vpc_security_group.bastion.id,
      yandex_vpc_security_group.LAN.id
    ]
  }
}

# Веб-сервер A
resource "yandex_compute_instance" "web_a" {
  name        = "web-a"
  hostname    = "web-a"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = var.CMCF.cores
    memory        = var.CMCF.memory
    core_fraction = var.CMCF.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_private_a.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.LAN.id,
      yandex_vpc_security_group.web_sg.id
    ]
  }
}

# Веб-сервер B
resource "yandex_compute_instance" "web_b" {
  name        = "web-b"
  hostname    = "web-b"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = var.CMCF.cores
    memory        = var.CMCF.memory
    core_fraction = var.CMCF.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_private_b.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.LAN.id,
      yandex_vpc_security_group.web_sg.id
    ]
  }
}

# Prometheus сервер
resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  hostname    = "prometheus"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = var.vm_sizes.medium.cores
    memory        = var.vm_sizes.medium.memory
    core_fraction = var.CMCF.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = var.vm_sizes.medium.disk
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_private_a.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.LAN.id,
      yandex_vpc_security_group.prometheus_sg.id
    ]
  }
}

# Grafana сервер
resource "yandex_compute_instance" "grafana" {
  name        = "grafana"
  hostname    = "grafana"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = var.vm_sizes.small.cores
    memory        = var.vm_sizes.small.memory
    core_fraction = var.CMCF.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = var.vm_sizes.small.disk
    }
  }

  metadata = {
    user-data          = file("./cloud-init-public.yml")  # Используем новый файл
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_public_a.id
    nat                = true
    nat_ip_address = yandex_vpc_address.grafana_ip.external_ipv4_address[0].address
    security_group_ids = [
      yandex_vpc_security_group.LAN.id,
      yandex_vpc_security_group.grafana_sg.id
    ]
  }
}

# Elasticsearch сервер
resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  hostname    = "elasticsearch"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = var.vm_sizes.large.cores
    memory        = var.vm_sizes.large.memory
    core_fraction = var.CMCF.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = var.vm_sizes.large.disk
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_private_a.id
    nat       = false
    security_group_ids = [
      yandex_vpc_security_group.LAN.id,
      yandex_vpc_security_group.elasticsearch_sg.id
    ]
  }
}

# Kibana сервер
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = var.vm_sizes.small.cores
    memory        = var.vm_sizes.small.memory
    core_fraction = var.CMCF.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = var.vm_sizes.small.disk
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_public_a.id
    nat       = true
    nat_ip_address = yandex_vpc_address.kibana_ip.external_ipv4_address[0].address
    security_group_ids = [
      yandex_vpc_security_group.LAN.id,
      yandex_vpc_security_group.kibana_sg.id
    ]
  }
}

# Target Group для балансировщика
resource "yandex_alb_target_group" "web_target_group" {
  name = "web-target-group-${var.flow}"

  target {
    subnet_id  = yandex_vpc_subnet.develop_private_a.id
    ip_address = yandex_compute_instance.web_a.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.develop_private_b.id
    ip_address = yandex_compute_instance.web_b.network_interface.0.ip_address
  }
}

# Backend Group
resource "yandex_alb_backend_group" "web_backend_group" {
  name = "web-backend-group-${var.flow}"

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_target_group.id]
    
    healthcheck {
      timeout             = "3s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 3
      
      http_healthcheck {
        path = "/health"
      }
    }
  }
}

# HTTP Router
resource "yandex_alb_http_router" "web_router" {
  name = "web-router-${var.flow}"
}

resource "yandex_alb_virtual_host" "web_virtual_host" {
  name           = "web-virtual-host-${var.flow}"
  http_router_id = yandex_alb_http_router.web_router.id
  authority      = ["*"]

  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_backend_group.id
        timeout          = "3s"
      }
    }
  }
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "web_balancer" {
  name               = "${var.balancer_name}-${var.flow}" # Здесь используем конкатенацию
  network_id         = yandex_vpc_network.develop.id
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.develop_public_a.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}

# Снапшоты для резервного копирования
resource "yandex_compute_snapshot_schedule" "daily_backup" {
  name = "daily-backup-${var.flow}"

  schedule_policy {
    expression = "0 1 * * *" # Ежедневно в 01:00
  }

  snapshot_count = 7 # Храним 7 снапшотов (неделя)

  snapshot_spec {
    description = "Daily backup"
  }

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web_a.boot_disk.0.disk_id,
    yandex_compute_instance.web_b.boot_disk.0.disk_id,
    yandex_compute_instance.prometheus.boot_disk.0.disk_id,
    yandex_compute_instance.grafana.boot_disk.0.disk_id,
    yandex_compute_instance.elasticsearch.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id
  ]
}

# Inventory файл для Ansible
resource "local_file" "inventory" {
  content  = <<-EOT
  [bastion]
  ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

  [webservers]
  ${yandex_compute_instance.web_a.network_interface.0.ip_address}
  ${yandex_compute_instance.web_b.network_interface.0.ip_address}

  [prometheus]
  ${yandex_compute_instance.prometheus.network_interface.0.ip_address}

  [grafana]
  ${yandex_compute_instance.grafana.network_interface.0.ip_address}

  [elasticsearch]
  ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}

  [kibana]
  ${yandex_compute_instance.kibana.network_interface.0.ip_address}

  [monitoring:children]
  prometheus
  grafana

  [logging:children]
  elasticsearch
  kibana

  [all:vars]
  ansible_user=nikolaym
  ansible_ssh_private_key_file=~/.ssh/id_ed25519
  ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  
  [webservers:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q nikolaym@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  
  [prometheus:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q nikolaym@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  
  [elasticsearch:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q nikolaym@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  
  [grafana:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q nikolaym@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  
  [kibana:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q nikolaym@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  EOT
  filename = "../ansible/inventory.ini"
}