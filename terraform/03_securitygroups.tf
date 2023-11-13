# ALB Security Group (Traffic Internet -> ALB)
resource "aws_security_group" "load-balancer" {
  name        = "load_balancer_security_group"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Fargate Security group (traffic ALB -> ECS Fargate Tasks)
resource "aws_security_group" "ecs-fargate" {
  name        = "ecs_fargate_security_group"
  description = "Allows inbound access from the ALB only"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load-balancer.id]
  }

  # No SSH ingress rule since Fargate tasks are abstracted and not directly accessible via SSH

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group (traffic Fargate -> RDS)
resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "Allows inbound access from Fargate only"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = "5432"
    to_port         = "5432"
    security_groups = [aws_security_group.ecs-fargate.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "EFS Security Group"
  description = "Allow ECS to EFS communication"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    from_port   = 2049  # NFS port
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Modify this based on your security requirements
  }
}
