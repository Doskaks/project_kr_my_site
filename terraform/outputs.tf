output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "alb_public_ip" {
  value = yandex_alb_load_balancer.web_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

output "grafana_public_ip" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "web_servers_ips" {
  value = {
    "web-a" = yandex_compute_instance.web_a.network_interface.0.ip_address
    "web-b" = yandex_compute_instance.web_b.network_interface.0.ip_address
  }
}

output "prometheus_ip" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
}

output "elasticsearch_ip" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
}