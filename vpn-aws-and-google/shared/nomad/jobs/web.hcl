job "web" {
  datacenters = ["us-east-1"]
  type        = "service"
  priority    = 50

  constraint {
    attribute = "$attr.kernel.name"
    value     = "linux"
  }

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "nginx" {
    count = 1

    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
    }

    task "nginx" {
      driver = "docker"

      config {
        image        = "hashidemo/nginx:latest"
        network_mode = "host"
      }

      service {
        name = "nginx"
        tags = ["global"]
        port = "http"

        check {
          name     = "nginx alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu = 500 # Mhz
        memory = 256 # MB

        network {
          mbits = 10

          # Request for a static port
          port "http" {
            static = 80
          }
        }
      }
    }
  }

  group "nodejs" {
    count = 3

    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
    }

    task "nodejs" {
      driver = "docker"

      config {
        image        = "hashidemo/nodejs:latest"
        network_mode = "host"
      }

      service {
        name = "nodejs"
        tags = ["global"]
        port = "http"

        check {
          name     = "nodejs alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        check {
          name     = "nodejs running on port 8080"
          type     = "http"
          protocol = "http"
          path     = "/"
          interval = "10s"
          timeout  = "1s"
        }
      }

      resources {
        cpu    = 500 # Mhz
        memory = 256 # MB

        network {
          mbits = 10

          port "http" {
          }
        }
      }
    }
  }
}
