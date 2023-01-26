resource "aws_iam_role" "slack_alerting_lambda_role" {
  name = "slack_alerting_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "permissions_for_sns" {
  name = "slack_alerting_for_sns"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Sid : "",
          Effect : "Allow",
          Action : [
            "SNS:Subscribe",
            "SNS:SetTopicAttributes",
            "SNS:RemovePermission",
            "SNS:Receive",
            "SNS:Publish",
            "SNS:ListSubscriptionsByTopic",
            "SNS:GetTopicAttributes",
            "SNS:DeleteTopic",
            "SNS:AddPermission",
          ],
          Resource : [
            aws_sns_topic.sns_slack_alert_topic.arn
          ]
        },
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "sqs_permissions" {
  role       = aws_iam_role.slack_alerting_lambda_role.name
  policy_arn = aws_iam_policy.permissions_for_sns.arn

  depends_on = [aws_iam_policy.permissions_for_sns, aws_iam_role.slack_alerting_lambda_role]
}

data "aws_iam_policy" "lambda_basic_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_basic_role_to_slack_lambda" {
  role = aws_iam_role.slack_alerting_lambda_role.name
  # this policy permits to log in cloudwatch
  policy_arn = data.aws_iam_policy.lambda_basic_execution_role.arn

  depends_on = [aws_iam_role.slack_alerting_lambda_role]
}

# Allow cloudwatch to invoke lambda

resource "aws_iam_role" "cloudwatch_role" {
  name_prefix = "cloudwatch-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
# Allow Cloudwatch to publish on SNS

resource "aws_sns_topic_policy" "slack_topic_policy" {
  arn    = aws_sns_topic.sns_slack_alert_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid       = "Allow CloudwatchEvents"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.sns_slack_alert_topic.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "cloudwatch.amazonaws.com"]
    }
  }
}