

output "backup_vault_id" {
  description = "The backup vault id."
  value       = aws_backup_vault.backup_vault.id
}

output "backup_plan_id" {
  description = "The backup plan id."
  value       = aws_backup_plan.backup_plan.id
}