resource "aws_ecr_repository" "django" {
  name                 = "${local.name}-django"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    ignore_changes = all
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command     = <<EOF
      cd ../app
      aws ecr get-login-password --region ${var.region} | docker login -u AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com
      docker build -t ${aws_ecr_repository.django.repository_url} .
      docker push ${aws_ecr_repository.django.repository_url}
      EOF
  }
}

resource "aws_ecr_repository" "nginx" {
  name                 = "${local.name}-nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    ignore_changes = all
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command     = <<EOF
      cd ../app
      aws ecr get-login-password --region ${var.region} | docker login -u AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com
      docker build -t ${aws_ecr_repository.nginx.repository_url} .
      docker push ${aws_ecr_repository.nginx.repository_url}
      EOF
  }
}