locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  name = lower(trimspace(var.name))
  document_name = "${local.environment}-${local.client}-${local.application}-${local.name}-ssm"
}

data template_file "ssm_content" {
  template = file("${path.module}/resources/ssm_content_template.json")
  vars = {
    command = replace(replace(var.ssm_content_command, "\"", "\\\""), "\n", "")
    description = var.ssm_content_description
  }
}

resource "aws_ssm_document" "ssm_document" {
  name = local.document_name
  document_type = "Command"
  content = data.template_file.ssm_content.rendered
  
  tags = {
    Name = local.document_name
    Application = local.application
    Environment = local.environment
    Client = local.client
  }
}

resource "aws_ssm_association" "ssm_association" {
  name = local.document_name

  targets {
    key    = "tag:Name"
    values = [var.ssm_association_tag]
  }
}