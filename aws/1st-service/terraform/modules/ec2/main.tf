resource "aws_instance" "app" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [var.existing_sg_id]

  # We omit user_data to avoid drift

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name        = "AppInstance"                   
    Environment = var.environment
    Project     = "aws-1st-service"
    ManagedBy   = "Terraform"
  }
}

