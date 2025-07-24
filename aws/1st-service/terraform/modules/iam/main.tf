data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "policies" {
  for_each = var.iam_policies

  name        = "${each.key}-${var.environment}"
  description = each.value.description
  policy      = file("${path.root}/${each.value.policy_filename}")
}

resource "aws_iam_role_policy_attachment" "attachments" {
  for_each = var.iam_policies

  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.policies[each.key].arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}
