resource "aws_key_pair" "default" {
  key_name   = local.name
  public_key = file(var.ssh_pubkey_file)
}
