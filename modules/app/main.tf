provider "aws" {
  region = var.region
}

resource "aws_security_group" "lb_app_sg" {
  name        = "lb_app_sg"
  description = "Allow traffic from web sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "lb_app_sg"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow inbound traffic from app lb"
  vpc_id      = var.vpc_id

  tags = {
    Name = "lb_app_sg"
  }
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_app_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "app_target_group" {
  name_prefix = "app-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "8000"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.api_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "app-instance-profile"
  role = aws_iam_role.instance_role.name
}

data "aws_iam_policy_document" "app_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "iam-instance-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_role.json
}
resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "secrets_manager" {
  name = "app-read-db-secret"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = var.db_secret_arn
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "test_attach_secret" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.secrets_manager.arn
}
resource "aws_launch_template" "app_launch_template" {
  name = "app-launch-template"

  block_device_mappings {
    device_name = var.device_name

    ebs {
      volume_size = var.ebs_volume_size[terraform.workspace]
    }
  }
  instance_type = var.instance_type[terraform.workspace]
  image_id      = var.image_id
  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data = base64encode(
    templatefile("${path.module}/user_data.sh", {
      ecr_image     = var.ecr_image_url
      ecr_image_tag = var.ecr_image_tag
      region        = var.region
    })
  )
}

resource "aws_iam_role_policy" "ecr_pull" {
  name = "ecr_pull"
  role = aws_iam_role.instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-autoscaling-group"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = var.private_subnet_ids
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      max_healthy_percentage = 100
      instance_warmup        = 300
      checkpoint_percentages = [1, 20, 100]
      checkpoint_delay       = 300
      alarm_specification {
        alarms = [
          "backend-unhealthy-hosts"
        ]
      }
      auto_rollback = true
    }

  }
  target_group_arns = [aws_lb_target_group.app_target_group.arn]

}


resource "aws_cloudwatch_metric_alarm" "cloudwatch_cpu_alarm" {
  alarm_name                = "cloudwatch_cpu_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}

resource "aws_sqs_queue" "user_updates_queue" {
  name   = "user-updates-queue"
  policy = data.aws_iam_policy_document.sqs_queue_policy.json
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.user_updates_queue.arn
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  policy_id = "arn:aws:sqs:${var.region}:${var.aws_account_id}:user_updates_queue/SQSDefaultPolicy"

  statement {
    sid    = "user_updates_sqs_target"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = ["arn:aws:sqs:${var.region}:${var.aws_account_id}:user-updates-queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sns_topic.user_updates.arn,
      ]
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthyhosts" {
  alarm_name          = "backend-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"
  threshold           = 1
  alarm_description   = "Number of unhealthy nodes in Target Group"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  ok_actions          = [aws_sns_topic.user_updates.arn]
  dimensions = {
    TargetGroup  = aws_lb_target_group.app_target_group.arn_suffix
    LoadBalancer = aws_lb.app_lb.arn_suffix
  }
}







