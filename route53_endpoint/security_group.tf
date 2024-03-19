resource "aws_security_group" "route53_endpoint_security_group" {
  name        = ("${var.environment}-${var.client}-route53endpoint-sg")
  description = "Security group for Route 53 Endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 53
    protocol  = "tcp"
    to_port   = 53
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = ("${var.environment}-${var.client}-route53endpoint-sg")
    Client = var.client
    Environment = var.environment
  }

}