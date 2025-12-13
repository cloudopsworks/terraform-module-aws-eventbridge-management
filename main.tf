##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  buses = {
    for bus_key, bus_config in var.event_buses : bus_key => {
      name   = format("%s-%s-event-bus", bus_key, local.system_name_short)
      config = bus_config
    }
  }
  rules = {
    for rule_key, rule_config in var.configs : rule_key => {
      name   = format("%s-%s-rule", rule_key, local.system_name_short)
      config = rule_config
    }
  }
  targets = merge([
    for rule_key, rule in local.rules : {
      for target in rule.config.targets : format("%s-%s", rule_key, target.target_id) => {
        rule_key    = rule_key
        target_type = target.type
        target_id   = target.target_id
        target      = target
      }
    }
  ]...)
  target_types = toset([
    for key, target in local.targets : target.target_type if target.target_type == "ssm"
  ])
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_bus" "this" {
  for_each           = local.buses
  name               = each.value.name
  description        = format("Event Bus for %s", each.key)
  kms_key_identifier = try(var.encryption.enabled, false) ? aws_kms_key.this[0].arn : try(each.value.config.kms_key_arn, each.value.config.kms_key_id, null)
  dynamic "dead_letter_config" {
    for_each = try(each.value.config.dead_letter_sns, "") != "" ? [1] : []
    content {
      arn = try(each.value.config.dead_letter_sns, null)
    }
  }
  log_config {
    include_detail = try(each.value.config.logs.include_detail, "FULL")
    level          = try(each.value.config.logs.level, "ERROR")
  }
  tags = merge(
    local.all_tags,
    try(each.value.config.tags, {}),
    {
      Name = each.value.name
    }
  )
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each            = local.rules
  name                = each.value.name
  description         = try(each.value.config.description, format("Event Rule for %s", each.key))
  event_bus_name      = try(each.value.config.event_bus_ref, "") != "" ? aws_cloudwatch_event_bus.this[each.value.config.event_bus_ref].name : "default"
  event_pattern       = try(jsonencode(each.value.config.event_pattern), each.value.config.event_pattern, null)
  schedule_expression = try(each.value.config.schedule, null)
  state               = try(each.value.config.state, true) ? "ENABLED" : "DISABLED"
  tags = merge(
    local.all_tags,
    try(each.value.config.tags, {}),
    {
      Name = each.value.name
    }
  )
}
