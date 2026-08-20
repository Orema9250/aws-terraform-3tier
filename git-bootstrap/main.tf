provider "aws" {
  region = var.region
}

resource "aws_iam_openid_connect_provider" "github_action" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

}

resource "aws_iam_role" "terraform_github_role" {
  name_prefix = "githubterraformrole"

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

resource "aws_iam_role_policy" "github_terraform_role_policy" {
  role = aws_iam_role.terraform_github_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ecrauthorizzationpolicy"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Sid    = "ecrpushpolicy"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = "arn:aws:ecr:us-east-1:556173312932:repository/backend"
      },

      {
        Sid = "TerrarformStateBucket"
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-terraform-state1234-bucket"
      },
      {
        Sid = "TerraformStateObject"
        Action = [
          "s3:GetObject", "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-terraform-state1234-bucket/orema/terraform.tfstate"
      },

      {
        Sid = "NetworkPermission"
        Action = [
          "ec2:CreateVpc", "ec2:CreateVpcEndpoint", "ec2:DeleteVpc", "ec2:DeleteVpcEndpoint", "ec2:DescribeVpc", "ec2:ModifyVpcAttribute", "ec2:AcceptVpcEndpointConnections",
          "ec2:CreateNatGateway", "ec2:DeleteNatGateway", "ec2:DescribeNatGateway",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:DescribeSubnet",
          "ec2:DeleteInternetGateway", "ec2:CreateInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway",
          "ec2:CreateRouteTable", "ec2:DescribeRouteTable", "ec2:AssociateRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute",
          "ec2:DescribeSecurityGroup", "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupEgress", "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AllocateAddress", "ec2:ReleaseAddress",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ComputePermission"
        Action = [
          "ec2:CreateLaunchTemplate", "ec2:DeleteLaunchTemplate",
          "autoscaling:CreateAutoScalingGroup", "autoscaling:DeleteAutoScalingGroup", "autoscaling:DescribeAutoScalingGroups", "autoscaling:UpdateAutoScalingGroup", "ec2:DescribeInstances", "ec2:RunInstances", "ec2:TerminateInstances", "ec2:RebootInstances",
          "elasticloadbalancing:CreateListener", "elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:CreateTargetGroup", "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer", "elasticloadbalancing:DeleteTargetGroup", "elasticloadbalancing:DescribeTargetGroups", "elasticloadbalancing:DescribeTargetHealth",
          "ec2:RunInstances", "ec2:TerminateInstances", "ec2:DescribeInstances",

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "FrontendPermission"
        Action = [
          "cloudfront:UpdateDistribution", "cloudfront:CreateDistribution", "cloudfront:CreateCachePolicy", "cloudfront:CreateOriginAccessControl",
          "cloudfront:DeleteCachePolicy", "cloudfront:DeleteDistribution", "cloudfront:DeleteOriginAccessControl",
          "route53:ListHostedZones", "route53:DeleteHostedZone", "route53:CreateHostedZone",
          "acm:DeleteCertificate", "acm:DescribeCertificate", "acm:ListCertificates", "acm:ImportCertificate",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "DatabasePermission"
        Action = [
          "rds:CreateDBInstance", "rds:DeleteDBInstance", "rds:DescribeDBInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid      = "SubnetGroupPermission"
        Action   = ["rds:CreateDBSubnetGroup", "rds:DeleteDBSubnetGroup", ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ManagedBucketPolicies"
        Action = [
          "s3:DeleteBucket", "s3:GetBucketLocation", "s3:GetBucketVersioning", "s3:PutBucketVersioning", "s3:GetBucketPolicy", "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy", "s3:GetEncryptionConfiguration", "s3:PutEncryptionConfiguration", "s3:GetBucketPublicAccessBlock", "s3:PutBucketPublicAccessBlock",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::frontend-bucket-version-9250/*"

      },

      {
        Sid      = "CreateBucketPolicy"
        Action   = ["s3:CreateBucket"]
        Effect   = "Allow"
        Resource = "*"
      },

      {
        Sid    = "PassOnlyEC2ApplicationRole"
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = "arn:aws:iam::556173312932:role/iam-instance-role"

        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      },

      {
        Sid = "ManagedInstanceProfiles"
        Action = [
          "iam:DeleteInstanceProfile", "iam:CreateInstanceProfile", "iam:AddRoleToInstanceProfile",
          "iam:GetInstanceProfile", "iam:RemoveRoleFromInstanceProfile",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}