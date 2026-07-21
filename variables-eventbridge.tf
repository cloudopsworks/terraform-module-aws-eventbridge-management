##
# (c) 2021-2026
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
#     dead_letter_sqs: "arn:aws:sns:..."  # (Optional) SNS topic ARN for dead-letter queueing of failed event deliveries. Default: null
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
#         version: null               # (Optional, ssm) Optional SSM Document version name. Default: null
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
## YAML reference for `scheduler_groups`
# scheduler_groups:                       # (Optional) Map of EventBridge Scheduler schedule group definitions. Default: {}
#   <group_key>:                           # (Required for groups) Arbitrary key used by schedulers.<key>.group_ref.
#     name: "ops-jobs"                    # (Optional) Explicit group name. Default: <group_key>-<system_name_short>-scheduler-group
#     tags:                                # (Optional) Extra tags merged into the schedule group. Default: {}
#       Purpose: "scheduled-jobs"
#
# Behavior:
# - If `name` is omitted, each group is named `<group_key>-<system_name_short>-scheduler-group`.
# - Schedules can reference a managed group by setting `schedulers.*.group_ref` to the group key.
# - If no group_ref or group_name is provided on a schedule, AWS default schedule group `default` is used.
variable "scheduler_groups" {
  description = "A map of EventBridge Scheduler schedule group configurations."
  type        = any
  default     = {}
  nullable    = false
}

## YAML reference for `schedulers`
# schedulers:                             # (Optional) Map of EventBridge Scheduler schedule definitions. Default: {}
#   <schedule_key>:                        # (Required for schedules) Arbitrary key used in naming and outputs.
#     name: "nightly-maintenance"         # (Optional) Explicit schedule name. Default: <schedule_key>-<system_name_short>-scheduler
#     description: "Run nightly job"      # (Optional) Schedule description. Default: "EventBridge Scheduler schedule for <schedule_key>"
#     group_ref: "ops"                    # (Optional) Key from scheduler_groups to use for group_name. Conflicts logically with group_name.
#     group_name: "default"               # (Optional) Existing Scheduler group name. Default: default
#     schedule_expression: "cron(0 2 * * ? *)" # (Required) Schedule expression: at(...), rate(...), or cron(...)
#     schedule_expression_timezone: "UTC" # (Optional) IANA timezone used to evaluate schedule_expression. Default: UTC
#     state: true                          # (Optional) true/ENABLED to enable, false/DISABLED to disable. Default: true
#     start_date: null                     # (Optional) UTC timestamp after which recurring schedules can invoke targets. Example: 2030-01-01T01:00:00Z
#     end_date: null                       # (Optional) UTC timestamp before which recurring schedules can invoke targets. Example: 2030-12-31T23:59:59Z
#     action_after_completion: "NONE"     # (Optional) Valid values: NONE | DELETE. Default: provider default NONE
#     kms_key_arn: null                    # (Optional) Customer-managed KMS key ARN for Scheduler data. Ignored when encryption.enabled=true.
#     flexible_time_window:                # (Optional) Invocation window. Default: { mode = "OFF" }
#       mode: "OFF"                       # (Required by AWS) Valid values: OFF | FLEXIBLE. Default: OFF
#       maximum_window_in_minutes: null    # (Optional) Required when mode=FLEXIBLE. Valid range: 1-1440 minutes.
#     target:                              # (Required) Target invoked by EventBridge Scheduler.
#       arn: "arn:aws:scheduler:::aws-sdk:sqs:sendMessage" # (Required) Target ARN or universal target service ARN.
#       role_arn: "arn:aws:iam::123456789012:role/scheduler-exec" # (Required) IAM role assumed by Scheduler.
#       input: {}                          # (Optional) String or object JSON payload passed to the target. Default: null
#       dead_letter_sqs: null              # (Optional) SQS DLQ ARN shorthand. Default: null
#       dead_letter_config:                # (Optional) SQS DLQ configuration; use instead of dead_letter_sqs for provider-shaped input.
#         arn: "arn:aws:sqs:..."          # (Required if block is set) DLQ queue ARN.
#       retry_policy:                      # (Optional) Target retry behavior. Default: AWS provider defaults
#         maximum_event_age_in_seconds: 86400 # (Optional) Valid range: 60-86400. Default: 86400
#         maximum_retry_attempts: 185      # (Optional) Valid range: 0-185. Default: 185
#       sqs_parameters:                    # (Optional) SQS target parameters.
#         message_group_id: "default"     # (Optional) FIFO message group ID.
#       eventbridge_parameters:            # (Optional) EventBridge PutEvents target parameters.
#         detail_type: "MaintenanceJob"   # (Required if block is set) Event detail type.
#         source: "custom.maintenance"    # (Required if block is set) Event source.
#       kinesis_parameters:                # (Optional) Kinesis target parameters.
#         partition_key: "job-key"        # (Required if block is set) Kinesis partition key.
#       ecs_parameters:                    # (Optional) ECS RunTask target parameters.
#         task_definition_arn: "arn:aws:ecs:...:task-definition/job:1" # (Required if block is set) Task definition ARN.
#         launch_type: "FARGATE"          # (Optional) Valid values: EC2 | FARGATE | EXTERNAL.
#         task_count: 1                    # (Optional) Number of tasks. Valid range: 1-10. Default: 1
#         network_configuration:           # (Optional) ECS task network configuration.
#           assign_public_ip: false        # (Optional) Assign public IP for Fargate. Default: false
#           security_groups: []            # (Optional) Security group IDs, 1-5 values.
#           subnets: []                    # (Optional) Subnet IDs, 1-16 values.
#       sagemaker_pipeline_parameters:     # (Optional) SageMaker pipeline target parameters.
#         pipeline_parameter:              # (Optional) List of SageMaker pipeline parameters, up to 200.
#           - name: "Environment"         # (Required) Pipeline parameter name.
#             value: "prod"               # (Required) Pipeline parameter value.
#
# Behavior:
# - Each schedule will be named `<schedule_key>-<system_name_short>-scheduler` unless `name` is provided.
# - The module manages Scheduler groups and schedules separately from EventBridge Rules in `configs`.
# - `target.role_arn` must allow `scheduler.amazonaws.com` to assume it and invoke the selected target.
variable "schedulers" {
  description = "A map of EventBridge Scheduler schedule configurations."
  type        = any
  default     = {}
  nullable    = false
}
