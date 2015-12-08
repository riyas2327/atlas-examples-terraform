job "batch" {
  datacenters = ["us-east-1"]

  type = "batch"

  constraint {
    attribute = "$attr.kernel.name"
    value = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "batch" {
    count = 50

    task "uptime" {
      driver = "exec"

      service {
        # name = "uptime"
        tags = ["uptime"]
        port = "uptime"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        command = "uptime"
      }

      resources {
        cpu = 100 # 500 Mhz
        memory = 128 # 256MB

        network {
          mbits = 10

          # Request for a dynamic port
          port "uptime" {
          }
        }
      }
    }
  }
}
