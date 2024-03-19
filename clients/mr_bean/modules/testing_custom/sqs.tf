locals {
  client = var.client
  application = "alcyon-backoffice"
  region = var.region
  environment = lower(trimspace(var.environment))
  prefix = "${local.environment}-${local.client}-${local.application}"
}

module "sqs_kms_key" {
  source = "../../../../templates/kms"
  application = local.application
  client = local.client
  environment = var.environment 
  name = "mr-bean-sqs"
}

module "sqs_ca_print_notice_events" {
  source = "../../../../templates/sqs"
  name = "ca-print-notice-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_ca_print_letter_events" {
  source = "../../../../templates/sqs"
  name = "ca-print-letter-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_ca_image_transform_events" {
  source = "../../../../templates/sqs"
  name = "ca-image-transform-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_cask_print_notice_events" {
  source = "../../../../templates/sqs"
  name = "cask-print-notice-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_cask_print_letter_events" {
  source = "../../../../templates/sqs"
  name = "cask-print-letter-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_cask_image_transform_events" {
  source = "../../../../templates/sqs"
  name = "cask-image-transform-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_nsw_print_notice_events" {
  source = "../../../../templates/sqs"
  name = "nsw-print-notice-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_nsw_print_letter_events" {
  source = "../../../../templates/sqs"
  name = "nsw-print-letter-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_nsw_image_transform_events" {
  source = "../../../../templates/sqs"
  name = "nsw-image-transform-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_usa_print_notice_events" {
  source = "../../../../templates/sqs"
  name = "usa-print-notice-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_usa_print_letter_events" {
  source = "../../../../templates/sqs"
  name = "usa-print-letter-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_usa_image_transform_events" {
  source = "../../../../templates/sqs"
  name = "usa-image-transform-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_au_wa_print_notice_events" {
  source = "../../../../templates/sqs"
  name = "au-wa-print-notice-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_au_wa_print_letter_events" {
  source = "../../../../templates/sqs"
  name = "au-wa-print-letter-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_au_wa_image_transform_events" {
  source = "../../../../templates/sqs"
  name = "au-wa-image-transform-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_au_nt_print_notice_events" {
  source = "../../../../templates/sqs"
  name = "au-nt-print-notice-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_au_nt_print_letter_events" {
  source = "../../../../templates/sqs"
  name = "au-nt-print-letter-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}

module "sqs_au_nt_image_transform_events" {
  source = "../../../../templates/sqs"
  name = "au-nt-image-transform-events"
  application = local.application
  sqs_kms_key_arn = module.sqs_kms_key.kms_key_arn
  client = local.client
  environment = var.environment
  alarm_sns_topic_arn = var.alarm_sns_topic_arn
}
