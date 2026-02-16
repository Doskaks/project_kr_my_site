# Создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop-fops-${var.flow}"
}

# Создаем приватную подсеть zone A для веб-серверов и мониторинга
resource "yandex_vpc_subnet" "develop_private_a" {
  name           = "develop-fops-${var.flow}-ru-central1-a-private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

# Создаем приватную подсеть zone B для веб-серверов
resource "yandex_vpc_subnet" "develop_private_b" {
  name           = "develop-fops-${var.flow}-ru-central1-b-private"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

# Создаем публичную подсеть zone A для балансировщика, Grafana и Kibana
resource "yandex_vpc_subnet" "develop_public_a" {
  name           = "develop-fops-${var.flow}-ru-central1-a-public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.3.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

# Создаем NAT для выхода в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "fops-gateway-${var.flow}"
  shared_egress_gateway {}
}

# Создаем сетевой маршрут для выхода в интернет через NAT
resource "yandex_vpc_route_table" "rt" {
  name       = "fops-route-table-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Группы безопасности
resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id
  
  ingress {
    description    = "Allow SSH from anywhere"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "LAN" {
  name       = "LAN-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id
  
  ingress {
    description    = "Allow internal network"
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 0
    to_port        = 65535
  }
  
  ingress {
    description       = "Allow SSH from bastion"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description       = "Allow HTTP from ALB"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }
  
  ingress {
    description       = "Allow HTTPS from ALB"
    protocol          = "TCP"
    port              = 443
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }
  
  ingress {
    description    = "Allow health checks from Yandex Cloud"
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    port           = 80
  }
  
  ingress {
    description       = "Allow Node Exporter from Prometheus"
    protocol          = "TCP"
    port              = 9100
    security_group_id = yandex_vpc_security_group.prometheus_sg.id
  }
  
  ingress {
    description       = "Allow Nginx Log Exporter from Prometheus"
    protocol          = "TCP"
    port              = 9113
    security_group_id = yandex_vpc_security_group.prometheus_sg.id
  }
  
  # УДАЛЕНО: egress правило с ссылкой на elasticsearch_sg
  # Filebeat будет использовать общее egress правило ниже
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "prometheus_sg" {
  name       = "prometheus-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description       = "Allow Prometheus UI from Grafana"
    protocol          = "TCP"
    port              = 9090
    security_group_id = yandex_vpc_security_group.grafana_sg.id
  }
  
  ingress {
    description       = "Allow Prometheus UI from bastion"
    protocol          = "TCP"
    port              = 9090
    security_group_id = yandex_vpc_security_group.bastion.id
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "grafana_sg" {
  name       = "grafana-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "Allow Grafana from anywhere"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }
  
  # Добавьте это правило для SSH
  ingress {
    description    = "Allow SSH from anywhere"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  ingress {
    description       = "Allow HTTP from ALB"
    protocol          = "TCP"
    port              = 3000
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "elasticsearch_sg" {
  name       = "elasticsearch-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  # Разрешаем доступ от веб-серверов по IP-адресам, а не по security group
  ingress {
    description    = "Allow Elasticsearch from web servers"
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = [
      "${yandex_compute_instance.web_a.network_interface.0.ip_address}/32",
      "${yandex_compute_instance.web_b.network_interface.0.ip_address}/32"
    ]
  }
  
  # Разрешаем доступ от Kibana
  ingress {
    description       = "Allow Elasticsearch from Kibana"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana_sg.id
  }
  
  # Разрешаем доступ от bastion для управления
  ingress {
    description       = "Allow Elasticsearch from bastion"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.bastion.id
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "kibana_sg" {
  name       = "kibana-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  # Веб-доступ к Kibana
  ingress {
    description    = "Allow Kibana from anywhere"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  # SSH только из группы безопасности bastion
  ingress {
    description       = "SSH from bastion security group"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  # Исходящий трафик
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "Allow HTTP from anywhere"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  ingress {
    description    = "Allow HTTPS from anywhere"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  
  # Явно разрешаем порты для health checks (стандартные порты для HTTP)
  ingress {
    description    = "Allow health checks on port 80"
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    port           = 80
  }
  
  ingress {
    description    = "Allow health checks on port 443"
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    port           = 443
  }
  
  # Разрешаем health checks на нестандартные порты, если они используются
  ingress {
    description    = "Allow health checks on custom ports"
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 1024
    to_port        = 65535
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}