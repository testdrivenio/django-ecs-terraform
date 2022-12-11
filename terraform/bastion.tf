resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
  tags = {
    Name = "${local.name}-bastion"
  }
}

resource "aws_instance" "bastion" {
  ami                    = lookup(var.amis, var.region)
  instance_type          = "t2.micro"
  key_name               = local.name
  tags                   = { Name = "${local.name}-bastion" }
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.public_1.id
}