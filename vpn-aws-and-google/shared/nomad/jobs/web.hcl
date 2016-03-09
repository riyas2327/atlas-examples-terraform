job "web" {
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

  group "nginx" {
    count = 1

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
    }

    task "nginx" {
      driver = "docker"

      config {
        image        = "hashidemo/nginx:latest"
        network_mode = "host"
      }

      resources {
        cpu    = 20 # Mhz
        memory = 15 # MB
        disk   = 10 # MB

        network {
          mbits = 1

          port "http" {
            static = 80
          }
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        NODEJS_ADDR = "redis"
        NODEJS_TYPE = "query"
        NODE_CLASS  = "${node.class}"
      }

      service {
        name = "nginx"
        tags = ["global", "${JOB}", "${TASKGROUP}"]
        port = "http"

        check {
          name     = "nginx alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

  group "nodejs" {
    count = 3

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
    }

    task "nodejs" {
      driver = "docker"

      config {
        image        = "hashidemo/nodejs:latest"
        network_mode = "host"
      }

      resources {
        cpu    = 20 # Mhz
        memory = 15 # MB
        disk   = 10 # MB

        network {
          mbits = 1

          port "http" {
          }
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        REDIS_ADDR = "redis.query.consul"
        REDIS_PORT = "6379"
        NODE_CLASS = "${node.class}"
      }

      service {
        name = "nodejs"
        tags = ["global", "${JOB}", "${TASKGROUP}"]
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
    }
  }
}
