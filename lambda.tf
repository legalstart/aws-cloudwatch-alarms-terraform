data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.root}/python_slack_client" # Directory where your Python source code is
  output_path = "${path.root}/slack_alerting.zip"
}


resource "aws_lambda_function" "send_message_slack" {
  function_name = "send_message_slack"
  role          = aws_iam_role.slack_alerting_lambda_role.arn
  filename      = "${path.root}/slack_alerting.zip"
  handler       = "main.lambda_handler"
  timeout       = 60
  memory_size   = 256
  runtime       = "python3.8"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      SLACK_CHANNEL     = var.slack_channel
      SLACK_USERNAME    = var.slack_username
    }
  }

  depends_on = [
    data.archive_file.src,
    aws_iam_role_policy_attachment.sqs_permissions,
    aws_iam_role_policy_attachment.attach_basic_role_to_slack_lambda,
  ]
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "allow_slack_lambda_exec_from_sns"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_message_slack.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns_slack_alert_topic.arn
}