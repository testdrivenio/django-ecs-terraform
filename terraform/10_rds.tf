resource "aws_db_subnet_group" "default" {
  name       = local.name
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "default" {
  identifier              = local.name
  db_name                    = var.rds_db_name
  username                = var.rds_username
  password                = var.rds_password
  port                    = "5432"
  engine                  = "postgres"
  engine_version          = "10.18"
  instance_class          = var.rds_instance_class
  allocated_storage       = "20"
  storage_encrypted       = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  multi_az                = false
  storage_type            = "gp2"
  publicly_accessible     = false
  backup_retention_period = 7
  skip_final_snapshot     = true
}
