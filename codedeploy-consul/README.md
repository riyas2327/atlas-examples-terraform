# codedeploy-consul

This example demonstrates using [Consul](https://www.consul.io/) for
service health checks and orchestrating deployments for an
[AWS CodeDeploy](https://aws.amazon.com/codedeploy/) application.

Specifically, Consul is used to:
- Register the CodeDeploy application in Consul's
[service catalog](https://www.consul.io/docs/agent/services.html) for service
discovery
- Mark the node as
["under maintenance"](https://www.consul.io/docs/commands/maint.html) during a
CodeDeploy deployment
- Prevent the CodeDeploy deployment from proceeding until the node and
application are healthy in Consul's service catalog
