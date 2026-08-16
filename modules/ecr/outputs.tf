output "ecr_image_url" {
  value = aws_ecr_repository.backend.repository_url
}