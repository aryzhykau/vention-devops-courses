resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] # only ALB SG allowed
  }

  # Optional: Allow SSH from your IP (update this before apply!)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["88.212.17.33/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_instance" "app" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "AppInstance"
  }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app.id
  port             = 80
}


