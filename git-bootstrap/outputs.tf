output "github_action_role_arn" {
  value = aws_iam_role.github_action_role.arn
}

output "terraform_github_role" {
  value = aws_iam_role.terraform_github_role.arn
}