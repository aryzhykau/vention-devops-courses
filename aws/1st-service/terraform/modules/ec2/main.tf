resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.existing_sg_id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile_name

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tmpl", {
    repo_url      = var.runner_repo_url
    runner_ver    = var.runner_version
    runner_labels = var.runner_labels
    runner_token  = var.runner_token == null ? "" : var.runner_token
  })

  tags = { Name = "ec2-${var.environment}" }
}



