// Usage of count in clients/ca_calgary/ca_calgary_main/sftp_server_eip blocks declaring provider block in this module
// since providers cannot be configured within modules using count, for_each or depends_on

locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  eip_name = "${local.environment}-${local.client}-${local.application}-eip"
}

resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = local.eip_name
    Application = local.application
    Environment = local.environment
    Client = local.client
  }
}