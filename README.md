
これにより、以下の流れで通知が行われます：

- IAMユーザー作成のAPIコールが発生
- CloudTrailがAPIコールを記録
- EventBridgeがCloudTrailのログからイベントを検知
- Lambda関数が起動
- SNS経由でメール通知


https://repost.aws/ja/knowledge-center/iam-eventbridge-sns-rule
