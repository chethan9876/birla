resource "aws_iam_role" "sns_feedback_role" {
  name = "${local.prefix}-sns-feedback-role-iam"
  assume_role_policy = data.aws_iam_policy_document.sns_assume_role_policy.json
  inline_policy {
    name = "${local.prefix}-sns-feedback-policy-iam"
    policy = data.aws_iam_policy_document.sns_feedback_policy.json
  }
}

resource "aws_iam_role" "vpc_flow_logs_policy" {
  name = "${local.prefix}-vpc_flow_logs-role-iam"
  assume_role_policy = data.aws_iam_policy_document.sns_assume_role_policy.json
  inline_policy {
    name = "${local.prefix}-sns-feedback-policy-iam"
    policy = data.aws_iam_policy_document.vpc_flow_log_policy.json
  }
}