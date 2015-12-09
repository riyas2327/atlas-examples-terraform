job "web" {
  # Run the job in the global region, which is the default.
  # region = "global"

  # Specify the datacenters within the region this job can run in.
  datacenters = ["us-east-1"]

  # Service type jobs optimize for long-lived services. This is
  # the default but we can change to batch for short-lived tasks.
  # type = "service"

  # Priority controls our access to resources and scheduling priority.
  # This can be 1 to 100, inclusively, and defaults to 50.
  # priority = 50

  # Restrict our job to only linux. We can specify multiple
  # constraints as needed.
  constraint {
    attribute = "$attr.kernel.name"
    value     = "linux"
  }

  # Configure the job to do rolling updates
  update {
    # Stagger updates every 10 seconds
    stagger = "10s"

    # Update a single task at a time
    max_parallel = 1
  }

  # Create a 'node' group. Each task in the group will be
  # scheduled onto the same machine.
  group "node" {
    # Control the number of instances of this groups.
    # Defaults to 1
    count = 3

    # Restart Policy - This block defines the restart policy for TaskGroups,
    # the attempts value defines the number of restarts Nomad will do if Tasks
    # in this TaskGroup fails in a rolling window of interval duration
    # The delay value makes Nomad wait for that duration to restart after a Task
    # fails or crashes.
    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
    }

    # Define a node task to run
    task "node" {
      # Use Docker to run the task.
      driver = "docker"

      # Configure Docker driver with the image
      config {
        image = "bensojona/node:latest"

        port_map {
          http  = 8080
        }
      }

      service {
        name = "${TASKGROUP}"
        tags = ["global", "web", "node"]
        port = "http"

        check {
          name     = "node alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        check {
          name     = "node running on port 8080"
          type     = "http"
          protocol = "http"
          path     = "/"
          interval = "10s"
          timeout  = "1s"
        }
      }

      env {
        REDIS_PORT_6379_TCP_PORT = "6379"
        REDIS_PORT_6379_TCP_ADDR = "redis"
      }

      # We must specify the resources required for
      # this task to ensure it runs on a machine with
      # enough capacity.
      resources {
        cpu = 500 # Mhz
        memory = 256 # MB

        network {
          mbits = 10

          # Request for a dynamic port
          port "http" {}
        }
      }
    }
  }

  # Create a 'nginx' group. Each task in the group will be
  # scheduled onto the same machine.
  group "nginx" {
    # Control the number of instances of this groups.
    # Defaults to 1
    # count = 1

    # Restart Policy - This block defines the restart policy for TaskGroups,
    # the attempts value defines the number of restarts Nomad will do if Tasks
    # in this TaskGroup fails in a rolling window of interval duration
    # The delay value makes Nomad wait for that duration to restart after a Task
    # fails or crashes.
    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
    }

    # Define a nginx task to run
    task "nginx" {
      # Use Docker to run the task.
      driver = "docker"

      # Configure Docker driver with the image
      config {
        image = "bensojona/nginx:latest"

        port_map {
          http  = 80
        }
      }

      service {
        name = "${TASKGROUP}"
        tags = ["global", "web", "nginx"]
        port = "http"

        check {
          name     = "nginx alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # We must specify the resources required for
      # this task to ensure it runs on a machine with
      # enough capacity.
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
}
