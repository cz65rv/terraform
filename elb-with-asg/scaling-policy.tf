################# Scaling policy to scale-out for high cpu usage

resource "aws_autoscaling_policy" "scaling-policy-up" {
  name                   = "scaling-policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}


#################### Cloudwatch alarm for high cpu usage

resource "aws_cloudwatch_metric_alarm" "cpu-usage-up" {
  alarm_name          = "cpu-usage-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm-period
  statistic           = "Average"
  threshold           = var.max-threshold
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scaling-policy-up.arn]
}


################## Scaling policy to scale-in for high cpu usage

resource "aws_autoscaling_policy" "scaling-policy-down" {
  name                   = "scaling-policy-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}


################### Cloudwatch alarm for low cpu usage

resource "aws_cloudwatch_metric_alarm" "cpu-usage-down" {
  alarm_name          = "cpu-usage-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm-period
  statistic           = "Average"
  threshold           = var.min-threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scaling-policy-down.arn]
}