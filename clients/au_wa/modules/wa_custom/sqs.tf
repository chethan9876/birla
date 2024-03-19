module "sqs_kms_key" {
  source = "../../../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment 
  name = "au-wa-sqs"
}

module "payment_due_notification_events" {
  source = "../../../../templates/sqs"
  name = "payment-due-notification-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "ingestr_incoming_oe_file_events" {
  source = "../../../../templates/sqs"
  name = "ingestr-incoming-oe-file-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "payment_received_events" {
  source = "../../../../templates/sqs"
  name = "payment-received-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}