job "web-client" {
  datacenters = ["us-east-1","us-central1"]
  type        = "service"
  priority    = 50

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "web-client" {
    count = 1

    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
      mode     = "delay"
    }

    task "web-client" {
      driver = "exec"

      config {
        artifact_source = "https://s3.amazonaws.com/hashicorp-cameron-public/projects/go-test-web-client/bin/go-test-web-client"
        checksum        = "md5:5bd44d6ee5d6130c49cf1f7766d3d524"
        command         = "go-test-web-server"
      }

      env {
        NODE_DATACENTER = "${node.datacenter}"
        REDIS_ADDRESS   = "redis.query.consul:6379"
        REQUEST_ADDRESS = "http://go-test-web-server.query.consul:8000/"
      }

      service {
        name = "web-client"
        tags = ["global"]
        port = "none"

        /*check {
          name     = "web-server alive"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }*/
      }

      resources {
        cpu = 500 # Mhz
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
