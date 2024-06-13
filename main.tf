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
    image     = "ravinder143/helloworldnodeapp:1",  # Replace with your Docker image URI
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
  memory                   = "512"  # Define memory at the task level
  execution_role_arn       = "arn:aws:iam::851725329984:role/ecsTaskExecutionRole"  # Use the provided ARN
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids  # Use default subnets
    security_groups = ["sg-028ca2cf7f38cd3f1"]      # Replace with your security group IDs
    assign_public_ip = true  # Ensure the task gets a public IP if in a public subnet
  }
}
