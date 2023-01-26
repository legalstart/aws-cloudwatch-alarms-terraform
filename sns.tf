resource "aws_sns_topic" "sns_slack_alert_topic" {
  name = "slack-alerting"
}

resource "aws_sns_topic_subscription" "sns_notify_slack" {
  topic_arn = aws_sns_topic.sns_slack_alert_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.send_message_slack.arn
}