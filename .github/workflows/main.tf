provider "aws" {
  region = "us-east-2"  # Change this to your desired region
}

# Retrieve default VPC and its subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task-definition"
  container_definitions    = jsonencode([{
    name      = "my-container",
    image     = "shiva8639/helloapp:1",  # Replace with your Docker image URI
    cpu       = 256,
    memory    = 512,
    essential = true,
    portMappings = [{
      containerPort = 3000,
      hostPort      = 3000,
      protocol      = "tcp",
    }]
  }])

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]  # Ensure compatibility with Fargate
  cpu                      = "256"  # Define CPU at the task level
  memory                   = "512"  # Define memory at t
