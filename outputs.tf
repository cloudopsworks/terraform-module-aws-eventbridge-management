##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "event_bus_names" {
  description = "Names of EventBridge event buses created by this module, keyed by event_buses key."
  value       = { for key, bus in aws_cloudwatch_event_bus.this : key => bus.name }
}

output "event_bus_arns" {
  description = "ARNs of EventBridge event buses created by this module, keyed by event_buses key."
  value       = { for key, bus in aws_cloudwatch_event_bus.this : key => bus.arn }
}

output "event_rule_names" {
  description = "Names of EventBridge rules created by this module, keyed by configs key."
  value       = { for key, rule in aws_cloudwatch_event_rule.this : key => rule.name }
}

output "event_rule_arns" {
  description = "ARNs of EventBridge rules created by this module, keyed by configs key."
  value       = { for key, rule in aws_cloudwatch_event_rule.this : key => rule.arn }
}

output "ssm_document_names" {
  description = "Names of SSM documents created for EventBridge SSM targets, keyed by rule and target."
  value       = { for key, document in aws_ssm_document.ssm_doc : key => document.name }
}

output "ssm_document_arns" {
  description = "ARNs of SSM documents created for EventBridge SSM targets, keyed by rule and target."
  value       = { for key, document in aws_ssm_document.ssm_doc : key => document.arn }
}

output "scheduler_group_names" {
  description = "Names of EventBridge Scheduler schedule groups created by this module, keyed by scheduler_groups key."
  value       = { for key, group in aws_scheduler_schedule_group.this : key => group.name }
}

output "scheduler_group_arns" {
  description = "ARNs of EventBridge Scheduler schedule groups created by this module, keyed by scheduler_groups key."
  value       = { for key, group in aws_scheduler_schedule_group.this : key => group.arn }
}

output "scheduler_schedule_names" {
  description = "Names of EventBridge Scheduler schedules created by this module, keyed by schedulers key."
  value       = { for key, schedule in aws_scheduler_schedule.this : key => schedule.name }
}

output "scheduler_schedule_arns" {
  description = "ARNs of EventBridge Scheduler schedules created by this module, keyed by schedulers key."
  value       = { for key, schedule in aws_scheduler_schedule.this : key => schedule.arn }
}

output "kms_key_arn" {
  description = "ARN of the module-managed KMS key when encryption.enabled is true; null when no module-managed key is created."
  value       = try(aws_kms_key.this[0].arn, null)
}
