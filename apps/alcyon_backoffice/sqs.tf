module "sqs_kms_key" {
  source = "../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment
  name = "sqs"
}

module "sqs_deployment_events" {
  source = "../../templates/sqs"
  name = "deployment-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_print_notice_events" {
  source = "../../templates/sqs"
  name = "print-notice-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
  max_receive_count = 5
}

module "sqs_adjudication_export_events" {
  source = "../../templates/sqs"
  name = "adjudication-export-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_court_export_events" {
  source = "../../templates/sqs"
  name = "court-export-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_collection_events" {
  source = "../../templates/sqs"
  name = "collection-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_collection_paymentupdate_events" {
  source = "../../templates/sqs"
  name = "collection-paymentupdate-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_print_letter_events" {
  source = "../../templates/sqs"
  name = "print-letter-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_ingestr_incoming_file_events" {
  source = "../../templates/sqs"
  name = "ingestr-incoming-file-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_image_transform_events" {
  source = "../../templates/sqs"
  name = "image-transform-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_trafficstatsingestr_incoming_file_events" {
  source = "../../templates/sqs"
  name = "trafficstatsingestr-incoming-file-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_notifyr_mail_trigger_events" {
  source = "../../templates/sqs"
  name = "notifyr-mail-trigger-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}


module "sqs_toh_events" {
  source = "../../templates/sqs"
  name = "toh-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}