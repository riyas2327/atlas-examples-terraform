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

      config {
        image = "nginx"
      }

      resources {
        cpu = 500 # 500 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
          reserved_ports = [80,443]
        }
      }
    }
  }

}
