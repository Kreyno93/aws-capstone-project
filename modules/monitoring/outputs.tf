output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "log_group_names" {
  description = "Names of the CloudWatch log groups"
  value = {
    apache_access    = aws_cloudwatch_log_group.apache_access.name
    apache_error     = aws_cloudwatch_log_group.apache_error.name
    bastion_secure   = aws_cloudwatch_log_group.bastion_secure.name
    bastion_messages = aws_cloudwatch_log_group.bastion_messages.name
  }
}
