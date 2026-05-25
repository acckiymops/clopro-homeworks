resource "yandex_lb_network_load_balancer" "my_balancer" {
  name = "lamp-balancer"
  
  listener {
    name = "http-listener"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp-ig.load_balancer[0].target_group_id
    
    healthcheck {
      name = "http-healthcheck"
      interval = 2
      timeout = 1
      unhealthy_threshold = 2
      healthy_threshold = 2
      
      http_options {
        port = 80
        path = "/health"
      }
    }
  }
}
