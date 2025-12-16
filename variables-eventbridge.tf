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
#   deletion_window: 30                   # (Optional) KMS key deletion window in days. Allowed values: 7-30. Default: 30
#   key_rotation: true                    # (Optional) Enable automatic key rotation. Default: true
#   rotation_period: 90                   # (Optional) Rotation period in days (if supported by AWS). Default: 90
#   multi_region: false                   # (Optional) Create a multi-Region KMS key. Default: false
#
# Notes:
# - When `enabled` is true, the module creates a KMS key and uses it for EventBridge buses and their CloudWatch Log Groups.
# - When `enabled` is false, you can set per-bus keys with `event_buses.*.kms_key_arn|kms_key_id` and per-bus log keys with `event_buses.*.log_kms_key_arn|log_kms_key_id`.
# - Use either ARN or Key ID when providing existing keys; ARN takes precedence if both are set.
variable "encryption" {
  description = "Enable encryption for EventBridge resources."
  type        = any
  default     = {}
  nullable    = false
}

## YAML reference for `event_buses`
# event_buses:                            # (Optional) Map of event bus definitions. Default: {}
#   <bus_key>:                             # (Required for custom buses) Arbitrary key used in naming.
#     kms_key_arn: "arn:aws:kms:..."      # (Optional) Existing KMS key ARN for this bus (ignored if encryption.enabled=true)
#     kms_key_id: "1234abcd-..."          # (Optional) Existing KMS key ID for this bus (ignored if encryption.enabled=true)
#     dead_letter_sns: "arn:aws:sns:..."  # (Optional) SNS topic ARN for dead-letter queueing of failed event deliveries. Default: null
#     logs:                                # (Optional) EventBridge logging configuration for this bus. Default: { include_detail = "FULL", level = "ERROR" }
#       include_detail: "FULL"            # (Optional) Allowed: FULL | BASIC. Default: FULL
#       level: "ERROR"                    # (Optional) Allowed: ERROR | INFO | TRACE. Default: ERROR
#     log_retention: 7                     # (Optional) CloudWatch Log Group retention (days). Common: 1,3,5,7,14,30,90,120,180,365,... Default: 7
#     log_kms_key_arn: "arn:aws:kms:..."  # (Optional) KMS ARN for this bus' log group (ignored if encryption.enabled=true)
#     log_kms_key_id: "1234abcd-..."      # (Optional) KMS Key ID for this bus' log group (ignored if encryption.enabled=true)
#     tags:                                # (Optional) Extra tags merged into this bus resources. Default: {}
#       Owner: "team-x"
#       CostCenter: "cc-123"
#
# Behavior:
# - Each bus will be named `<bus_key>-<system_name_short>-event-bus` by the module.
# - The default AWS event bus is available even if `event_buses` is empty.
# - CloudWatch Log resources and delivery are provisioned per bus when logging is enabled by AWS.
variable "event_buses" {
  description = "A map of EventBridge bus configurations."
  type        = any
  default     = {}
  nullable    = false
}


## YAML reference for `configs`
# configs:                                # (Optional) Map of rule configurations. Default: {}
#   <rule_key>:                            # (Required for rules) Arbitrary key used in naming.
#     description: "Process EC2 events"   # (Optional) Rule description. Default: "Event Rule for <rule_key>"
#     event_bus_ref: "<bus_key>"          # (Optional) Reference to a key in `event_buses`. Default: AWS default event bus
#     event_pattern:                       # (Required if `schedule` unset) EventBridge event pattern (object or JSON string)
#       source: ["aws.ec2"]               #   Example pattern fields
#       detail-type: ["EC2 Instance State-change Notification"]
#       detail:
#         state: ["stopped", "terminated"]
#     schedule: "rate(5 minutes)"         # (Required if `event_pattern` unset) Schedule expression: cron(...) or rate(...)
#     state: true                          # (Optional) true => ENABLED, false => DISABLED. Default: true
#     tags:                                # (Optional) Extra tags for the rule. Default: {}
#       Purpose: "ops"
#     targets:                             # (Optional) List of targets for this rule. Default: []
#       - type: "ssm"                      # (Required) Target type. Supported values: ssm
#         target_id: "terminate-by-tag"    # (Required) Unique ID for the target within the rule
#         document_type: "Command"         # (Optional, ssm) SSM Document type. Allowed: Command | Automation. Default: Command
#         version_name: null               # (Optional, ssm) Optional SSM Document version name. Default: null
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
#           - key: "tag:Terminate"        #   Key format examples: tag:Name, tag:Terminate, InstanceIds
#             values: ["true"]            #   Values is a list of strings; e.g., instance IDs or tag values
#         tags:                            # (Optional, ssm) Tags for the created SSM Document. Default: {}
#           Name: "terminate-by-tag"
#
# Rules behavior & constraints:
# - A rule will be named `<rule_key>-<system_name_short>-rule`.
# - Exactly one of `event_pattern` or `schedule` must be provided.
# - For SSM targets, the module creates: aws_ssm_document, aws_cloudwatch_event_target, and an IAM role/policy (once per module) to allow events to call SSM.
variable "configs" {
  description = "A map of EventBridge Rules & Target configurations."
  type        = any
  default     = {}
  nullable    = false
}