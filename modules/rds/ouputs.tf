output "db_secret_arn" {
  value = aws_db_instance.instance.master_user_secret[0].secret_arn
}

output "db_endpoint" {
  value = aws_db_instance.instance.address
}

output "db_port" {
  value = aws_db_instance.instance.port
}

output "db_name" {
  value = aws_db_instance.instance.db_name
}