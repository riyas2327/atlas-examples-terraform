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
        cpu = 100 # Mhz
        memory = 128 # MB

        network {
          mbits = 10

          # Request for a dynamic port
          port "nginx" {
          }

          # Request for a static port
          port "http" {
            static = 80
          }

          # Request for a static port
          port "https" {
            static = 443
          }
        }
      }
    }
  }
}
