##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  scheduler_groups = {
    for group_key, group_config in var.scheduler_groups : group_key => {
      name   = try(group_config.name, null) != null && try(group_config.name, "") != "" ? group_config.name : format("%s-%s-scheduler-group", group_key, local.system_name_short)
      config = group_config
    }
  }
  scheduler_schedules = {
    for schedule_key, schedule_config in var.schedulers : schedule_key => {
      name   = try(schedule_config.name, null) != null && try(schedule_config.name, "") != "" ? schedule_config.name : format("%s-%s-scheduler", schedule_key, local.system_name_short)
      config = schedule_config
    }
  }
}

resource "aws_scheduler_schedule_group" "this" {
  for_each = local.scheduler_groups

  name = each.value.name
  tags = merge(
    local.all_tags,
    try(each.value.config.tags, {}),
    {
      Name = each.value.name
    }
  )
}

resource "aws_scheduler_schedule" "this" {
  for_each = local.scheduler_schedules

  name                         = each.value.name
  description                  = try(each.value.config.description, null) != null && try(each.value.config.description, "") != "" ? each.value.config.description : format("EventBridge Scheduler schedule for %s", each.key)
  group_name                   = try(each.value.config.group_ref, null) != null && try(each.value.config.group_ref, "") != "" ? aws_scheduler_schedule_group.this[each.value.config.group_ref].name : try(each.value.config.group_name, null) != null && try(each.value.config.group_name, "") != "" ? each.value.config.group_name : "default"
  schedule_expression          = each.value.config.schedule_expression
  schedule_expression_timezone = try(each.value.config.schedule_expression_timezone, null) != null && try(each.value.config.schedule_expression_timezone, "") != "" ? each.value.config.schedule_expression_timezone : "UTC"
  state                        = try(each.value.config.state, true) == true ? "ENABLED" : try(each.value.config.state, true) == false ? "DISABLED" : try(upper(tostring(each.value.config.state)), "ENABLED")
  start_date                   = try(each.value.config.start_date, null)
  end_date                     = try(each.value.config.end_date, null)
  action_after_completion      = try(each.value.config.action_after_completion, null)
  kms_key_arn                  = try(var.encryption.enabled, false) ? aws_kms_key.this[0].arn : try(each.value.config.kms_key_arn, null)

  flexible_time_window {
    mode                      = try(each.value.config.flexible_time_window.mode, null) != null && try(each.value.config.flexible_time_window.mode, "") != "" ? each.value.config.flexible_time_window.mode : "OFF"
    maximum_window_in_minutes = try(each.value.config.flexible_time_window.maximum_window_in_minutes, null)
  }

  target {
    arn      = each.value.config.target.arn
    role_arn = each.value.config.target.role_arn
    input    = try(tostring(each.value.config.target.input), jsonencode(each.value.config.target.input), null)

    dynamic "dead_letter_config" {
      for_each = try(each.value.config.target.dead_letter_config, null) != null || (try(each.value.config.target.dead_letter_sqs, null) != null && try(each.value.config.target.dead_letter_sqs, "") != "") ? [try(each.value.config.target.dead_letter_config, { arn = each.value.config.target.dead_letter_sqs })] : []
      content {
        arn = try(dead_letter_config.value.arn, dead_letter_config.value, null)
      }
    }

    dynamic "retry_policy" {
      for_each = try(each.value.config.target.retry_policy, null) != null ? [each.value.config.target.retry_policy] : []
      content {
        maximum_event_age_in_seconds = try(retry_policy.value.maximum_event_age_in_seconds, null)
        maximum_retry_attempts       = try(retry_policy.value.maximum_retry_attempts, null)
      }
    }

    dynamic "sqs_parameters" {
      for_each = try(each.value.config.target.sqs_parameters, null) != null ? [each.value.config.target.sqs_parameters] : []
      content {
        message_group_id = try(sqs_parameters.value.message_group_id, null)
      }
    }

    dynamic "eventbridge_parameters" {
      for_each = try(each.value.config.target.eventbridge_parameters, null) != null ? [each.value.config.target.eventbridge_parameters] : []
      content {
        detail_type = eventbridge_parameters.value.detail_type
        source      = eventbridge_parameters.value.source
      }
    }

    dynamic "kinesis_parameters" {
      for_each = try(each.value.config.target.kinesis_parameters, null) != null ? [each.value.config.target.kinesis_parameters] : []
      content {
        partition_key = kinesis_parameters.value.partition_key
      }
    }

    dynamic "ecs_parameters" {
      for_each = try(each.value.config.target.ecs_parameters, null) != null ? [each.value.config.target.ecs_parameters] : []
      content {
        task_definition_arn     = ecs_parameters.value.task_definition_arn
        enable_ecs_managed_tags = try(ecs_parameters.value.enable_ecs_managed_tags, null)
        enable_execute_command  = try(ecs_parameters.value.enable_execute_command, null)
        group                   = try(ecs_parameters.value.group, null)
        launch_type             = try(ecs_parameters.value.launch_type, null)
        platform_version        = try(ecs_parameters.value.platform_version, null)
        propagate_tags          = try(ecs_parameters.value.propagate_tags, null)
        reference_id            = try(ecs_parameters.value.reference_id, null)
        tags                    = try(ecs_parameters.value.tags, null)
        task_count              = try(ecs_parameters.value.task_count, null)

        dynamic "capacity_provider_strategy" {
          for_each = try(ecs_parameters.value.capacity_provider_strategy[*], [])
          content {
            base              = try(capacity_provider_strategy.value.base, null)
            capacity_provider = capacity_provider_strategy.value.capacity_provider
            weight            = try(capacity_provider_strategy.value.weight, null)
          }
        }

        dynamic "network_configuration" {
          for_each = try(ecs_parameters.value.network_configuration, null) != null ? [ecs_parameters.value.network_configuration] : []
          content {
            assign_public_ip = try(network_configuration.value.assign_public_ip, null)
            security_groups  = try(network_configuration.value.security_groups, null)
            subnets          = try(network_configuration.value.subnets, null)
          }
        }

        dynamic "placement_constraints" {
          for_each = try(ecs_parameters.value.placement_constraints[*], [])
          content {
            expression = try(placement_constraints.value.expression, null)
            type       = placement_constraints.value.type
          }
        }

        dynamic "placement_strategy" {
          for_each = try(ecs_parameters.value.placement_strategy[*], [])
          content {
            field = try(placement_strategy.value.field, null)
            type  = placement_strategy.value.type
          }
        }
      }
    }

    dynamic "sagemaker_pipeline_parameters" {
      for_each = try(each.value.config.target.sagemaker_pipeline_parameters, null) != null ? [each.value.config.target.sagemaker_pipeline_parameters] : []
      content {
        dynamic "pipeline_parameter" {
          for_each = try(sagemaker_pipeline_parameters.value.pipeline_parameter[*], [])
          content {
            name  = pipeline_parameter.value.name
            value = pipeline_parameter.value.value
          }
        }
      }
    }
  }
}
