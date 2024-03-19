
locals {
  environment_map = var.environment_args == null ? [] : [var.environment_args]
}
resource "aws_lambda_function" "lambda_function" {
  filename = var.filename
  function_name = "${var.environment}-${var.client}-${var.application}-${var.function_name}-lambda-function"
  role = var.role
  handler = var.handler
  source_code_hash = var.source_hash
  runtime = var.runtime
  timeout = var.timeout
  memory_size = var.memory_size

  dynamic environment {
    for_each = local.environment_map
    content {
      variables = environment.value
    }
  }

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_security_group.id]
  }

  tags = {
    Name = "${var.function_name}-lambda-function"
    Application = var.application
    Environment = var.environment
    Client = var.client
  }

  layers = []
}

resource "aws_lambda_function_event_invoke_config" "lambda_function_invoke" {
  function_name = aws_lambda_function.lambda_function.function_name
  maximum_retry_attempts = 0
  maximum_event_age_in_seconds = var.timeout
  destination_config {
    on_failure {
      destination = var.sns_topic
    }
  }
}


resource "aws_lambda_permission" "lambda_permissions" {
  statement_id = var.statement
  action = var.action
  function_name = aws_lambda_function.lambda_function.function_name
  principal = var.principal
  source_arn = var.source_arn
}