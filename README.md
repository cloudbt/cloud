# container-build
```
# カスタムEventBus
resource "aws_cloudwatch_event_bus" "notification_bus" {
  name = var.custom_event_bus_name
}

# LambdaからEventBusへの権限設定用ポリシー
resource "aws_iam_policy" "custom_eventbridge_policy" {
  name        = "custom-eventbridge-put-events-policy-${local.stack_name}"
  description = "Policy for putting events to custom EventBridge"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "events:PutEvents"
        Resource = aws_cloudwatch_event_bus.notification_bus.arn
      }
    ]
  })
}

# ポリシーをLambdaロールにアタッチ
resource "aws_iam_role_policy_attachment" "custom_eventbridge_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_eventbridge_policy.arn
}# GitHub Webhook Terraform Configuration

provider "aws" {
  region = "us-east-1" # リージョンは適宜変更してください
}

# 変数定義
variable "github_webhook_secret" {
  type        = string
  description = "Github webhook secret"
  sensitive   = true
}

variable "event_bus_name" {
  type        = string
  description = "EventBridge event bus name"
  default     = "default"
}

variable "custom_event_bus_name" {
  type        = string
  description = "Custom EventBridge event bus name for Lambda notifications"
  default     = "webhook-notification-bus"
}

variable "lambda_invocation_threshold" {
  type        = string
  description = "Innovation Alarm Threshold for number of events in a 5 minute period."
  default     = "2000"
}

variable "alarm_email" {
  type        = string
  description = "Email address to send alarm notifications to"
  default     = ""
}

# スタック名の代替として使用するランダムIDの生成
resource "random_id" "stack_id" {
  byte_length = 8
}

locals {
  stack_name = "github-webhook-${random_id.stack_id.hex}"
  stack_id_split = random_id.stack_id.hex
}

# Secrets Managerリソース
resource "aws_secretsmanager_secret" "webhook_secret" {
  name        = "WebhookSecret-${local.stack_name}"
  description = "Secrets Manager for storing Webhook Secret"
}

resource "aws_secretsmanager_secret_version" "webhook_secret_version" {
  secret_id     = aws_secretsmanager_secret.webhook_secret.id
  secret_string = var.github_webhook_secret
}

# Lambda関数
resource "aws_lambda_function" "webhook_function" {
  function_name = "InboundWebhook-Lambda-${substr(local.stack_id_split, 0, 8)}"
  
  # S3からコードを取得
  s3_bucket = "eventbridge-inbound-webhook-templates-prod-${data.aws_region.current.name}"
  s3_key    = "lambda-templates/github-lambdasrc.zip"
  
  handler = "app.lambda_handler"
  runtime = "python3.11"
  
  memory_size = 128
  timeout     = 100
  
    # エンバイロメント変数
  environment {
    variables = {
      GITHUB_WEBHOOK_SECRET_ARN = aws_secretsmanager_secret.webhook_secret.arn
      EVENT_BUS_NAME           = var.event_bus_name
      CUSTOM_EVENT_BUS_NAME    = aws_cloudwatch_event_bus.notification_bus.name
    }
  }
  
  # IAMロールをアタッチ
  role = aws_iam_role.lambda_role.arn
  
  depends_on = [
    aws_secretsmanager_secret.webhook_secret
  ]
}

# Lambda Function URL
resource "aws_lambda_function_url" "webhook_function_url" {
  function_name      = aws_lambda_function.webhook_function.function_name
  authorization_type = "NONE"
}

# Lambda用IAMロール
resource "aws_iam_role" "lambda_role" {
  name = "lambda-webhook-role-${local.stack_name}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# EventBridge用ポリシー
resource "aws_iam_policy" "eventbridge_policy" {
  name        = "eventbridge-put-events-policy-${local.stack_name}"
  description = "Policy for putting events to EventBridge"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "events:PutEvents"
        Resource = "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_name}"
      }
    ]
  })
}

# SecretsManager用ポリシー
resource "aws_iam_policy" "secretsmanager_policy" {
  name        = "secretsmanager-access-policy-${local.stack_name}"
  description = "Policy for accessing Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.webhook_secret.arn
      }
    ]
  })
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "eventbridge_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.eventbridge_policy.arn
}

resource "aws_iam_role_policy_attachment" "secretsmanager_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secretsmanager_policy.arn
}

# SNSトピック
resource "aws_sns_topic" "alarm_topic" {
  name = "webhook-alarm-topic-${local.stack_name}"
}

# SNSトピックのサブスクリプション（メール通知）
resource "aws_sns_topic_subscription" "alarm_email_subscription" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_invocations_alarm" {
  alarm_name          = "InboundWebhook-Lambda-Invocation-Alarm-${local.stack_name}"
  alarm_description   = "Alarm for ${local.stack_name} - InboundWebhook Lambda for traffic spikes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.lambda_invocation_threshold
  
  dimensions = {
    FunctionName = aws_lambda_function.webhook_function.function_name
  }
  
  # アラーム発生時にSNSトピックに通知
  alarm_actions = [aws_sns_topic.alarm_topic.arn]
  ok_actions    = [aws_sns_topic.alarm_topic.arn]
}

# データソース
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# 出力
output "function_url_endpoint" {
  description = "Webhook Function URL Endpoint"
  value       = aws_lambda_function_url.webhook_function_url.function_url
}

output "lambda_function_name" {
  value = aws_lambda_function.webhook_function.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN."
  value       = aws_lambda_function.webhook_function.arn
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for alarm notifications"
  value       = aws_sns_topic.alarm_topic.arn
}

output "custom_event_bus_arn" {
  description = "Custom EventBridge Event Bus ARN"
  value       = aws_cloudwatch_event_bus.notification_bus.arn
}

output "custom_event_bus_name" {
  description = "Custom EventBridge Event Bus Name"
  value       = aws_cloudwatch_event_bus.notification_bus.name
}
```



```
version: 0.2

phases:
  build:
    commands:
      - |
        bash \
          ./codebuild/test.sh

#!/bin/bash/env bash
set -euvx

echo "AWS Region: $AWS_REGION"
echo "CodeBuild Build ARN: $CODEBUILD_BUILD_ARN"
echo "CodeBuild Build ID: $CODEBUILD_BUILD_ID"
echo "CodeBuild Resolved Source Version: $CODEBUILD_RESOLVED_SOURCE_VERSION"
echo "CodeBuild Source Repository URL: $CODEBUILD_SOURCE_REPO_URL"
echo "CodeBuild Source Version: $CODEBUILD_SOURCE_VERSION"
```
