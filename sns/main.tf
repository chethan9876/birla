locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name = lower(trimspace(var.name))
  topic_name = "${local.environment}-${local.client}-${local.application}-${local.name}-sns"
}

//TODO: Setup delivery policy and also add a default value for it
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic#example-with-delivery-policy
resource "aws_sns_topic" "sns_topic" {
  name = local.topic_name
  kms_master_key_id = var.kms_key_id
  http_success_feedback_role_arn = var.feedback_role_arn
  http_failure_feedback_role_arn = var.feedback_role_arn

  tags = {
    Name = local.topic_name
    Application = local.application
    Client = local.client
    Environment = local.environment
  }
}