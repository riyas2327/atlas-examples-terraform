job "web-server" {
  datacenters = ["us-east-1"]
  type        = "system"
  priority    = 50

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "web-server" {
    count = 1

    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
      mode     = "delay"
    }

    task "web-server" {
      driver = "exec"

      config {
        artifact_source = "https://s3.amazonaws.com/hashicorp-cameron-public/projects/go-test-web-server/bin/go-test-web-server"
        checksum        = "md5:2cc355efdfcca6ada286bb654a7c3188"
        command         = "go-test-web-server"
      }

      env {
        NODE_DATACENTER = "${node.datacenter}"
        REDIS_ADDRESS   = "redis.query.consul:6379"
      }

      service {
        name = "web-server"
        tags = ["global"]
        port = "http"

        check {
          name     = "web-server alive"
          type     = "http"
          path     = "/health"
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
            static = 8000
          }
        }
      }
    }
  }

}
