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

      config {
        command = "uptime"
      }

      resources {
        cpu = 100 # 500 Mhz
        memory = 128 # 256MB
        network {
          mbits = 10
        }
      }
    }
  }

}
