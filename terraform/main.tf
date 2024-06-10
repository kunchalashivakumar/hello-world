provider "aws" {
  region = "us-east-2"  # Change this to your desired region
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
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-059ba7753915b3213"]  # Replace with your subnet IDs
    security_groups = ["sg-028ca2cf7f38cd3f1"]      # Replace with your security group IDs
  }
}


