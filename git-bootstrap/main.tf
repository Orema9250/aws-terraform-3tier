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
        Sid    = "EcrManagement"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          "ecr:DeleteRepository",
          "ecr:TagResource",
          "ecr:UntagResource",
        ]

        Resource = "*"
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
          "s3:GetObject", "s3:PutObject", "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-terraform-state1234-bucket/*"
      },
      {
        Sid    = "CloudWatchAlarmManagement"
        Effect = "Allow"

        Action = [
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:TagResource",
          "cloudwatch:UntagResource",
          "cloudwatch:ListTagsForResource",
        ]

        Resource = "*"
      },

      {
        Sid = "NetworkManagement"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc", "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcAttribute",
          "ec2:CreateTags",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "ec2:DeleteInternetGateway",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:AssociateRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:DescribeInternetGateways",
          "ec2:DescribePrefixLists",
          "ec2:DescribeNetworkInterfaces",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "SecurityGroupsManagement"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
        ]
        Effect   = "Allow"
        Resource = "*"

      },
      {
        Sid = "VpcEndpointsManagement"
        Action = [
          "ec2:CreateVpcEndpoint",
          "ec2:DeleteVpcEndpoint",
          "ec2:AcceptVpcEndpointConnections",
          "ec2:DescribeVpcEndpoints",
          "ec2:ModifyVpcEndpoint",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "NatgatewayManagement"
        Action = [
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways",
        ]
        Effect   = "Allow"
        Resource = "*"

      },
      {
        Sid = "ElasticIpAdderessManagement"
        Action = [
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ELBManagement"
        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListenerAttributes",

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "InstanceManagement"
        Action = [
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:RebootInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",

        ]
        Effect   = "Allow"
        Resource = "*"

      },
      {
        Sid = "AutoscalingGroupManagement"
        Action = [
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DescribeScalingActivities",
        ]
        Effect   = "Allow"
        Resource = "*"

      },

      {
        Sid    = "LaunchTemplateManagement"
        Effect = "Allow"

        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:CreateLaunchTemplateVersion",
        ]

        Resource = "*"
      },
      {
        Sid = "FrontendPermission"
        Action = [
          "cloudfront:UpdateDistribution",
          "cloudfront:CreateDistribution",
          "cloudfront:CreateCachePolicy",
          "cloudfront:CreateOriginAccessControl",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:GetCachePolicy",
          "cloudfront:TagResource",
          "cloudfront:GetDistribution",
          "cloudfront:DeleteCachePolicy",
          "cloudfront:DeleteDistribution",
          "cloudfront:DeleteOriginAccessControl",
          "cloudfront:ListTagsForResource",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CertificateManagement"
        Action = [
          "acm:DeleteCertificate",
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ImportCertificate",
          "acm:RequestCertificate",
          "acm:ListTagsForCertificate",
          "acm:AddTagsToCertificate",
          "acm:RemoveTagsFromCertificate",
        ]
        Effect   = "Allow"
        Resource = "*"

      },
      {
        Sid    = "HostedZones"
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetChange",
        ]
        Resource = "*"
      },
      {
        Sid    = "HostedZonePermissions"
        Effect = "Allow"
        Action = [
          "route53:GetHostedZone",
          "route53:ChangeResourceRecordSets",
          "route53:ListTagsForResource",
          "route53:ListResourceRecordSets",

        ]
        "Resource" : "arn:aws:route53:::hostedzone/Z09707871Z9DLD9Y1T6O0"
      },
      {
        Sid = "DatabaseManagement"
        Action = [
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance",
          "rds:DescribeDBInstances",
          "rds:AddTagsToResource",
          "rds:ListTagsForResource",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "SubnetGroupManagement"
        Action = [
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:DescribeDBSubnetGroups",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid    = "SecretsManagerForRDS"
        Effect = "Allow"

        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:TagResource"
        ]

        Resource = "*"
      },
      {
        Sid    = "KMSForRDSSecrets"
        Effect = "Allow"

        Action = [
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]

        Resource = "*"
      },
      {
        Sid    = "FrontendBucketManagement"
        Effect = "Allow"

        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",

          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",

          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",

          "s3:GetBucketAcl",
          "s3:PutBucketAcl",

          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock",


          "s3:GetEncryptionConfiguration",
          "s3:PutEncryptionConfiguration",

          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetAccelerateConfiguration",

          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:DeleteBucketTagging",

          "s3:GetBucketRequestPayment",
          "s3:GetBucketLogging",

          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetBucketObjectLockConfiguration",

          "s3:PutBucketOwnershipControls",
          "s3:GetBucketOwnershipControls",
        ]

        Resource = "arn:aws:s3:::frontend-bucket-version-9250"
      },
      {
        Sid    = "SQSManagement"
        Effect = "Allow"

        Action = [
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:GetQueueAttributes",
          "sqs:SetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ListQueueTags",
          "sqs:TagQueue",
          "sqs:UntagQueue"
        ]

        Resource = "arn:aws:sqs:us-east-1:556173312932:user-updates-queue"
      },
      {
        Sid = "SNSTopicManagement"
        Action = [
          "sns:CreateTopic",
          "sns:DeleteTopic",
          "sns:ListTopics",
          "sns:ConfirmSubscription",
          "sns:Subscribe",
          "sns:GetSubscriptionAttributes",
          "sns:SetTopicAttributes",
          "sns:GetTopicAttributes",
          "sns:ListTagsForResource",
        ]
        Effect   = "Allow"
        Resource = "*"
      },

      {
        Sid = "FrontendObjects"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",

        ]

        Effect   = "Allow"
        Resource = "arn:aws:s3:::frontend-bucket-version-9250/*"
      },

      {
        Sid = "CreateBucketPermission"
        Action = [
          "s3:CreateBucket",
        ]
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
          "iam:DeleteInstanceProfile",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:CreateRole",
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:GetRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:CreatePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:DeletePolicy",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "ecr_github_role" {
  name_prefix = "githubecrrole"

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

resource "aws_iam_role_policy" "github_ecr_role_policy" {
  role = aws_iam_role.ecr_github_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EcrAuthorization"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
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
          "ecr:UploadLayerPart",
        ]

        Resource = "arn:aws:ecr:us-east-1:556173312932:repository/backend"
      },
    ]
  })
}