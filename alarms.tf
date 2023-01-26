resource "aws_cloudwatch_metric_alarm" "monitor_cpu_usage" {
  alarm_name                = "monitor-ec2-instance"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  period                    = "60"
  datapoints_to_alarm       = "2"
  insufficient_data_actions = []
  alarm_description         = "It looks like at least one EC2 instance of the cluster has a very high CPU usage."
  alarm_actions = [
    aws_sns_topic.sns_slack_alert_topic.arn
  ]
  ok_actions = [
    aws_sns_topic.sns_slack_alert_topic.arn
  ]
  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = var.ecs_cluster_name
  }
  statistic = "Average"
  threshold = "80"
}

resource "aws_cloudwatch_metric_alarm" "monitor_containers_cpu_usage" {
  alarm_name                = "monitor-containers-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  datapoints_to_alarm       = "2"
  threshold                 = "80"
  insufficient_data_actions = []
  alarm_description         = "It looks like at least one container of the cluster has a very high CPU usage."
  alarm_actions = [
    aws_sns_topic.sns_slack_alert_topic.arn
  ]
  ok_actions = [
    aws_sns_topic.sns_slack_alert_topic.arn
  ]

  metric_query {
    id          = "e1"
    expression  = "100*m1/m2"
    label       = "CPU Usage"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "CpuUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Average"

      dimensions = {
        ClusterName = var.ecs_cluster_name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "CpuReserved"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Maximum"

      dimensions = {
        ClusterName = var.ecs_cluster_name
      }
    }
  }
}