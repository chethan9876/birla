

resource "aws_iam_role" "backup_role" {
  name               = "${local.prefix}-backup-role-iam"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY

  tags = {
    Name = ("${var.environment}-${var.client}-backuprole")
    Client = var.client
    Environment = var.environment
  }
}


resource "aws_iam_role_policy_attachment" "backup_role_cluster_policy_attachment" {
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

# Tag policy
resource "aws_iam_policy" "backup_policy" {

  description = "AWS Backup Tag policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "backup:TagResource",
            "backup:ListTags",
            "backup:UntagResource",
            "tag:GetResources"
        ],
        "Resource": "*"
    }
  ]
}
EOF
  tags = {
    Name = ("${var.environment}-${var.client}-backup-policy")
    Client = var.client
    Environment = var.environment
  }
}


resource "aws_iam_role_policy_attachment" "backup_role_policy_attachment" {
  policy_arn = aws_iam_policy.backup_policy.arn
  role       = aws_iam_role.backup_role.name
}


# Restores policy
resource "aws_iam_role_policy_attachment" "backup_restores_policy_attachment" {
  policy_arn = "${var.iam_arn_prefix}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_role.name
}
