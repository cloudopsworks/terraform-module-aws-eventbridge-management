##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## YAML reference for `encryption`
# encryption:                             # (Optional) Global KMS settings applied when enabled=true. Default: {}
#   enabled: true                         # (Optional) Enable module-managed KMS for EventBridge buses/logs. Default: false
#   deletion_window: 30                   # (Optional) KMS key deletion window in days. Allowed: 7-30. Default: 30
#   key_rotation: true                    # (Optional) Enable automatic key rotation. Default: true
#   rotation_period: 90                   # (Optional) Rotation period in days (if supported). Default: 90
#   multi_region: false                   # (Optional) Create a multi-Region KMS key. Default: false
#
# Notes:
# - When `enabled` is true, the module creates a KMS key and uses it for EventBridge buses and their log groups.
# - When `enabled` is false, you can set per-bus keys with `event_buses.*.kms_key_arn|kms_key_id` and per-bus log keys with `event_buses.*.log_kms_key_arn|log_kms_key_id`.
variable "encryption" {
  description = "Enable encryption for EventBridge resources."
  type        = any
  default     = {}
  nullable    = false
}

## YAML reference for `event_buses`
# event_buses:                            # (Optional) Map of event bus definitions. Default: {}
#   <bus_key>:
#     kms_key_arn: "arn:aws:kms:..."      # (Optional) Existing KMS key ARN for this bus (ignored if encryption.enabled=true)
#     kms_key_id: "1234abcd-..."          # (Optional) Existing KMS key ID for this bus (ignored if encryption.enabled=true)
#     dead_letter_sns: "arn:aws:sns:..."  # (Optional) SNS topic ARN for dead-letter queueing of failed event deliveries
#     logs:                                # (Optional) EventBridge logging configuration for this bus
#       include_detail: "FULL"            # (Optional) Detail level: FULL or BASIC. Default: FULL
#       level: "ERROR"                    # (Optional) Log level: ERROR | INFO | TRACE. Default: ERROR
#     log_retention: 7                     # (Optional) CloudWatch Log Group retention in days for this bus. Default: 7
#     log_kms_key_arn: "arn:aws:kms:..."  # (Optional) KMS ARN for the log group of this bus (ignored if encryption.enabled=true)
#     log_kms_key_id: "1234abcd-..."      # (Optional) KMS Key ID for the log group of this bus (ignored if encryption.enabled=true)
#     tags:                                # (Optional) Extra tags merged into this bus resources. Default: {}
#       Owner: "team-x"
#       CostCenter: "cc-123"
#
# Behavior:
# - Each bus will be named `<bus_key>-<system_name_short>-event-bus` by the module.
# - CloudWatch Log resources and delivery are provisioned per bus.
variable "event_buses" {
  description = "A map of EventBridge bus configurations."
  type        = any
  default     = {}
  nullable    = false
}


## YAML reference for `configs`
# configs:                                # (Optional) Map of rule configurations. Default: {}
#   <rule_key>:
#     description: "Process EC2 events"   # (Optional) Rule description. Default: "Event Rule for <rule_key>"
#     event_bus_ref: "<bus_key>"          # (Optional) Reference to a key in `event_buses`. Default: "default" EventBridge bus
#     event_pattern:                       # (Required if no schedule) EventBridge event pattern (object or JSON string)
#       source: ["aws.ec2"]               #   Example pattern fields
#       detail-type: ["EC2 Instance State-change Notification"]
#       detail:
#         state: ["stopped", "terminated"]
#     schedule: "rate(5 minutes)"         # (Required if no event_pattern) Schedule expression (cron(...) or rate(...))
#     state: true                          # (Optional) Enable the rule. true => ENABLED, false => DISABLED. Default: true
#     tags:                                # (Optional) Extra tags for the rule. Default: {}
#       Purpose: "ops"
#     targets:                             # (Optional) List of targets for this rule. Required for useful rules. Default: []
#       - type: "ssm"                      # (Required) Target type. Supported: ssm
#         target_id: "terminate-by-tag"    # (Required) A unique ID for the target within the rule
#         document_type: "Command"         # (Optional, ssm) SSM Document type. Common: Command, Automation. Default: Command
#         content:                          # (Required, ssm) SSM Document content (object or JSON string)
#           schemaVersion: "2.2"
#           description: "Terminate instances by tag"
#           mainSteps:
#             - action: "aws:runShellScript"
#               name: "terminate"
#               inputs:
#                 runCommand:
#                   - "#!/bin/bash"
#                   - "echo terminating"
#         run_command_targets:             # (Optional, ssm) EC2 selection via Run Command Targets. Default: []
#           - key: "tag:Terminate"        #   Example: target instances with the tag Terminate
#             values: ["true"]
#         tags:                            # (Optional, ssm) Tags for the created SSM Document
#           Name: "terminate-by-tag"
#
# Rules behavior:
# - A rule will be named `<rule_key>-<system_name_short>-rule`.
# - For SSM targets, the module creates: aws_ssm_document, aws_cloudwatch_event_target, and an IAM role/policy once per module enabling SSM.
variable "configs" {
  description = "A map of EventBridge Rules & Target configurations."
  type        = any
  default     = {}
  nullable    = false
}