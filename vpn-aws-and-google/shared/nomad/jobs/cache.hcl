job "cache" {
  datacenters = ["us-east-1","us-central1"]
  type        = "service"
  priority    = 50

  constraint {
    attribute = "${node.datacenter}"
    value     = "us-east-1"
  }

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "cache" {
    count = 1

    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
    }

    task "redis" {
      driver = "docker"

      config {
        image        = "hashidemo/redis:latest"
        network_mode = "host"

        port_map {
          db = 6379
        }
      }

      service {
        name = "redis"
        tags = ["global"]
        port = "db"

        check {
          name     = "redis alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500 # Mhz
        memory = 256 # MB

        network {
          mbits = 10

          port "db" {
            static = 6379
          }
        }
      }
    }
  }
}
