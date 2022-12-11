resource "aws_ecs_cluster" "default" {
  name = local.name
}

resource "aws_launch_configuration" "default" {
  name                        = local.name
  image_id                    = lookup(var.amis, var.region)
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ecs.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  key_name                    = aws_key_pair.default.key_name
  associate_public_ip_address = true
  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER='${local.name}' > /etc/ecs/ecs.config
  EOF
}

data "template_file" "default" {
  template = file("templates/apps.json.tpl")
  depends_on            = [aws_db_instance.default, aws_ecr_repository.django, aws_ecr_repository.nginx]
  vars = {
    docker_image_url_django = replace(aws_ecr_repository.django.repository_url, "https://", "")
    docker_image_url_nginx  = replace(aws_ecr_repository.nginx.repository_url, "https://", "")
    region                  = var.region
    rds_db_name             = var.rds_db_name
    rds_username            = var.rds_username
    rds_password            = var.rds_password
    rds_hostname            = aws_db_instance.default.address
    allowed_hosts           = var.allowed_hosts
    name                    = local.name
  }
}

resource "aws_ecs_task_definition" "default" {
  family                = local.name
  container_definitions = data.template_file.default.rendered
  depends_on            = [aws_db_instance.default]

  volume {
    name      = "static_volume"
    host_path = "/usr/src/app/staticfiles/"
  }
}
 
resource "aws_ecs_service" "default" {
  name            = local.name
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  iam_role        = aws_iam_role.ecs-service.arn
  desired_count   = var.app_count
  depends_on      = [aws_iam_role_policy.ecs-service]

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = "nginx"
    container_port   = 80
  }
}
