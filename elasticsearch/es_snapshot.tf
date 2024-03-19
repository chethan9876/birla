data "archive_file" "es_snapshot_lambda" {
  type = "zip"
  output_file_mode = "0644"
  source_dir = "${path.module}/resources/es_snapshot"
  output_path = "${path.module}/es_snapshot.zip"
}

module "take_snapshot_lambda_function" {
  source           = "../../templates/lambda"
  application      = local.application
  environment      = local.environment
  client           = local.client
  function_name    = "es-take-snapshot"
  filename         = data.archive_file.es_snapshot_lambda.output_path
  role             = aws_iam_role.es_snapshot_lambda_role.arn
  handler          = "es_snapshot.createSnapshot"
  source_hash      = data.archive_file.es_snapshot_lambda.output_base64sha256
  runtime          = "nodejs14.x"
  environment_args = {
    esEndpoint: aws_elasticsearch_domain.es_domain.endpoint
    region: var.region}
  subnet_ids       = var.subnet_ids
  vpc_id           = var.vpc_id
  sns_topic        = var.sns_topic
  statement        = "AllowExecutionFromCloudWatch"
  principal        = "events.amazonaws.com"
  source_arn       = aws_cloudwatch_event_rule.es_take_snapshot_schedule.arn
}

module "create_repo_lambda_function" {
  source           = "../../templates/lambda"
  application      = local.application
  environment      = local.environment
  client           = local.client
  function_name    = "es-create-repo"
  filename         = data.archive_file.es_snapshot_lambda.output_path
  role             = aws_iam_role.es_snapshot_lambda_role.arn
  handler          = "es_snapshot.createESSnapshotRepo"
  source_hash      = data.archive_file.es_snapshot_lambda.output_base64sha256
  runtime          = "nodejs14.x"
  environment_args = {
    esEndpoint: aws_elasticsearch_domain.es_domain.endpoint
    region: var.region
    bucketName: var.es_snapshot_s3_bucket
    roleARN: aws_iam_role.es_snapshot_lambda_role.arn}
  subnet_ids       = var.subnet_ids
  vpc_id           = var.vpc_id
  sns_topic        = var.sns_topic
  statement        = "AllowExecutionFromCloudWatch"
  principal        = "events.amazonaws.com"
  source_arn       = aws_cloudwatch_event_rule.create_repo_schedule.arn
}

module "delete_indices_lambda_function" {
  source           = "../../templates/lambda"
  application      = local.application
  environment      = local.environment
  client           = local.client
  function_name    = "es-delete-indices"
  filename         = data.archive_file.es_snapshot_lambda.output_path
  role             = aws_iam_role.es_snapshot_lambda_role.arn
  handler          = "es_snapshot.deleteIndices"
  source_hash      = data.archive_file.es_snapshot_lambda.output_base64sha256
  runtime          = "nodejs14.x"
  environment_args = {
    esEndpoint: aws_elasticsearch_domain.es_domain.endpoint
    region: var.region
    retentionDays: var.es_retention_days}
  subnet_ids       = var.subnet_ids
  vpc_id           = var.vpc_id
  sns_topic        = var.sns_topic
  statement        = "AllowExecutionFromCloudWatch"
  principal        = "events.amazonaws.com"
  source_arn       = aws_cloudwatch_event_rule.es_delete_indices_schedule.arn
}

resource "aws_cloudwatch_event_rule" "es_take_snapshot_schedule" {
  name = "${local.es_domain_name}-take-snapshot-cloudwatch-event-rule"
  description = "${local.es_domain_name}-take-snapshot-cloudwatch-event-rule"
  schedule_expression = var.es_take_snapshot_schedule

  tags = {
    Name = "${local.es_domain_name}-take-snapshot-cloudwatch-event-rule"
    Client = var.client
    Environment = var.environment
    }
}

resource "aws_cloudwatch_event_target" "es_snapshot_take_event_target" {
  target_id = "${local.es_domain_name}-es-snapshot-event-target"
  rule = aws_cloudwatch_event_rule.es_take_snapshot_schedule.name
  arn = module.take_snapshot_lambda_function.lambda_arn

//  tags = {
//    Name = "${local.es_domain_name}-es-snapshot-event-target"
//    Client = var.client
//    Environment = var.environment
//  }
}

resource "aws_cloudwatch_event_rule" "es_delete_indices_schedule" {
  name = "${local.es_domain_name}-delete-indices-cloudwatch-event-rule"
  description = "${local.es_domain_name}-delete-indices-cloudwatch-event-rule"
  schedule_expression = var.es_delete_indices_schedule

  tags = {
    Name = "${local.es_domain_name}-es-delete-indices-schedule"
    Client = var.client
    Environment = var.environment
    }
}

resource "aws_cloudwatch_event_target" "es_delete_index_event_target" {
  target_id = "${local.es_domain_name}-es-delete-indices-event-target"
  rule = aws_cloudwatch_event_rule.es_delete_indices_schedule.name
  arn = module.delete_indices_lambda_function.lambda_arn

//  tags = {
//    Name = "${local.es_domain_name}-es-delete-index-event-target"
//    Client = var.client
//    Environment = var.environment
//  }
}

resource "aws_cloudwatch_event_rule" "create_repo_schedule" {
  name = "${local.es_domain_name}-create-repo-cloudwatch-event-rule"
  description = "${local.es_domain_name}-create-repo-cloudwatch-event-rule"
  schedule_expression = var.es_delete_indices_schedule

  tags = {
    Name = "${local.es_domain_name}-create-repo-schedule"
    Client = var.client
    Environment = var.environment
  }
}