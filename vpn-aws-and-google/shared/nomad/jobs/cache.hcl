job "cache" {
  datacenters = ["us-east-1", "us-central1"]
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
        cpu    = 20 # Mhz
        memory = 15 # MB
        disk   = 10 # MB

        network {
          port "db" {
            static = 6379
          }
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        NODE_CLASS = "${node.class}"
      }

      service {
        name = "redis"
        tags = ["global", "${JOB}", "${TASKGROUP}"]
        port = "db"

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
