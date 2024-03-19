
resource "aws_security_group" "rds_security_group" {
  name = "${local.db_cluster_name}-sg"
  vpc_id = var.vpc_id
  description = "${local.db_cluster_name} security group"

  tags = {
    Name = "${local.db_cluster_name}-sg"
    Client = var.client
    Environment = var.environment
  }
}