resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.existing_sg_id]
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_name

  user_data                   = file("${path.module}/user_data.sh")

  tags = {
    Name = "ec2-${var.environment}"
  }
}


