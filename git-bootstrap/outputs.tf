output "terraform_github_role" {
  value = aws_iam_role.terraform_github_role.arn
}

output "ecr_github_role" {
  value = aws_iam_role.ecr_github_role.arn
}