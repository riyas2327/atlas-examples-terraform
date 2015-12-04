job "web" {
  datacenters = ["us-east-1"]

  type = "service"

  constraint {
    attribute = "$attr.kernel.name"
    value = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "web" {
    count = 3

    task "nginx" {
      driver = "docker"

      service {
        # name = "nginx"
        tags = ["nginx"]
        port = "nginx"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "nginx"
      }

      resources {
        cpu = 500 # 500 Mhz
        memory = 256 # 256MB

        network {
          mbits = 10
          reserved_ports = [80,443]

          # Request for a dynamic port
          port "nginx" {
          }
        }
      }
    }
  }

}
