output "db_secret_arn" {
  value = aws_db_instance.instance.master_user_secret[0].secret_arn
}
