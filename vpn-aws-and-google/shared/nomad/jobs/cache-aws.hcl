job "cache-aws" {
  datacenters = ["eu-central-1"]
  type        = "service"
  priority    = 50

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "redis" {
    count = 1

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
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

      resources {
        cpu    = 200 # Mhz
        memory = 200 # MB
        disk   = 10 # MB

        network {
          mbits = 1

          port "db" {
            static = 6379
          }
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      service {
        name = "redis"
        port = "db"
        tags = ["global"]

        check {
          name     = "redis alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
