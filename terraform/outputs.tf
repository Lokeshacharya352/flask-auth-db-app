
output "db_name" {
  value = aws_db_instance.mysql.db_name
}

output "db_endpoint" {
  description = "RDS endpoint (host:port) — use the host portion as MYSQL_HOST"
  value       = aws_db_instance.mysql.endpoint
}

output "db_host" {
  description = "RDS hostname only (no port) — this is what MYSQL_HOST should be set to"
  value       = aws_db_instance.mysql.address
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "db_security_group_id" {
  description = "Security group ID attached to RDS — useful for cross-referencing / auditing allowed access"
  value       = aws_security_group.db_sg.id
}
