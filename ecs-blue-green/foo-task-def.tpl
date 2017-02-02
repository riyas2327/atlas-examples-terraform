[
  {
    "name": "${task_name}",
    "image": "${task_image}:${version}",
    "cpu": 10,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
