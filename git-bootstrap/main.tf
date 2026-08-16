provider "aws" {
 region = var.region 
}

resource "aws_iam_openid_connect_provider" "github_action" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

}
resource "aws_iam_role" "github_action_role" {
  name_prefix = "githubrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = { 
          Federated = aws_iam_openid_connect_provider.github_action.arn
        }
       
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"

            "token.actions.githubusercontent.com:sub" = "repo:Orema9250@242164193/aws-terraform-3tier@1335039067:ref:refs/heads/main"
          }
        }
      
        }
    
    ]
})
}  
resource "aws_iam_role_policy" "github_ecr" {
  role = aws_iam_role.github_action_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = "arn:aws:ecr:us-east-1:556173312932:repository/backend"
      }
    ]
  })
}