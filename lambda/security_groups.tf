resource "aws_security_group" "lambda_security_group" {
  name = "${var.environment}-${var.client}-${var.application}-${var.function_name}-lambda-sg"
  description = "Security group for ${var.function_name} Lambda"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.environment}-${var.client}-${var.application}-${var.function_name}-lambda-sg"
    Client = var.environment
    Environment = var.environment
    Application = var.application
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}
