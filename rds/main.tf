locals {
  application = lower(trimspace(var.application))
  client = lower(trimspace(var.client))
  environment = lower(trimspace(var.environment))
  db_cluster_name = "${local.environment}-${local.client}-${local.application}-rds"
}

provider aws {
  alias = "route53"
  profile = var.client == "us-govcloud" ? "us-govcloud-parent" : var.client == "ca-on" ? "default" : var.client
  region = "us-east-1"
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier = "${local.db_cluster_name}-cluster"
  database_name = var.db_name
  master_username = "postgres"
  master_password = data.aws_secretsmanager_secret_version.rds_secret_version.secret_string
  snapshot_identifier = var.db_snapshot_identifier
  storage_encrypted = true
  engine = "aurora-postgresql"
  engine_version = var.db_engine_version
  db_subnet_group_name = var.db_subnet_group_name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_cluster_param_group.name
  kms_key_id = var.db_kms_key_arn
  final_snapshot_identifier = "${local.db_cluster_name}-final-snapshot"
  backup_retention_period = 30
  deletion_protection = true
  copy_tags_to_snapshot = true
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  tags = {
    Name = local.db_cluster_name
    Application = local.application
    Environment = local.environment
    Client = local.client
  }

  lifecycle {
    ignore_changes = [
      master_username,
      master_password,
      database_name,
      engine_version
    ]
  }
}

resource "aws_rds_cluster_instance" "db_cluster_instance" {
  count = var.db_instance_count
  identifier = "${local.db_cluster_name}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.db_cluster.id
  engine = aws_rds_cluster.db_cluster.engine
  engine_version = aws_rds_cluster.db_cluster.engine_version
  instance_class = var.instance_class
  publicly_accessible = false
  db_subnet_group_name = var.db_subnet_group_name
  performance_insights_kms_key_id =  var.db_performance_insights_enabled == false ? null : var.db_kms_key_arn
  performance_insights_enabled = var.db_performance_insights_enabled
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  monitoring_interval = 60

  tags = {
    Name = local.db_cluster_name
    Application = local.application
    Environment = local.environment
    Client = local.client
  }

  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}

resource "aws_rds_cluster_parameter_group" "db_cluster_param_group" {
  name = "${local.db_cluster_name}-cluster-param-group"
  family = var.db_cluster_parameter_group_family
  description = "${local.db_cluster_name} DB Cluster param group"

  parameter {
    name = "rds.force_ssl"
    value = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name = "autovacuum"
    value = "1"
    apply_method = "pending-reboot"
  }

  tags = {
      Name = "${local.db_cluster_name}-cluster-param-group" 
      Environment = local.environment
      Application = local.client
      Client = local.client
    }
}
