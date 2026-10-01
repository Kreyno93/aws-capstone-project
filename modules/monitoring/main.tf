# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "apache_access" {
  name              = "/aws/ec2/apache/access"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-apache-access-logs"
  })
}

resource "aws_cloudwatch_log_group" "apache_error" {
  name              = "/aws/ec2/apache/error"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-apache-error-logs"
  })
}

resource "aws_cloudwatch_log_group" "bastion_secure" {
  name              = "/aws/ec2/bastion/secure"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-bastion-secure-logs"
  })
}

resource "aws_cloudwatch_log_group" "bastion_messages" {
  name              = "/aws/ec2/bastion/messages"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-bastion-messages-logs"
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Load Balancer Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.autoscaling_group_name],
            [".", "GroupInServiceInstances", ".", "."],
            [".", "GroupTotalInstances", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Auto Scaling Group Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id],
            [".", "DatabaseConnections", ".", "."],
            [".", "FreeableMemory", ".", "."],
            [".", "FreeStorageSpace", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "RDS Metrics"
          period  = 300
        }
      }
    ]
  })

  tags = var.tags
}

# Data source for current region
data "aws_region" "current" {}
