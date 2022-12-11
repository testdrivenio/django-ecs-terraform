resource "aws_iam_role" "ecs-host" {
  name = "${local.name}-ecs-host"
  assume_role_policy = file("policies/ecs-role.json")

  tags = {
    Name = "${local.name}-ecs-host"
  }
}

resource "aws_iam_role_policy" "ecs-instance" {
  name   = "${local.name}-ecs-instance"
  policy = file("policies/ecs-instance-role-policy.json")
  role   = aws_iam_role.ecs-host.id
}

resource "aws_iam_role" "ecs-service" {
  name = "${local.name}-ecs-service"
  assume_role_policy = file("policies/ecs-role.json")

  tags = {
    Name = "${local.name}-ecs-service"
  }
}

resource "aws_iam_role_policy" "ecs-service" {
  name   = "${local.name}-ecs-service"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs-service.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = local.name
  path = "/"
  role = aws_iam_role.ecs-host.name
}
