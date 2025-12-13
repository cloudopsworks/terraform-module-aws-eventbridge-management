##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "aws_cloudwatch_log_group" "this" {
  for_each          = local.buses
  name              = "/aws/events/${each.value.name}"
  retention_in_days = try(each.value.config.log_retention, 7)
  kms_key_id        = try(var.encryption.enabled, false) ? aws_kms_key.this[0].key_id : try(each.value.config.log_kms_key_arn, each.value.config.log_kms_key_id, null)
  tags = merge(
    local.all_tags,
    try(each.value.config.tags, {}),
    {
      event-bus = "${each.value.name}"
    }
  )
}

# CloudWatch Log Delivery Sources for INFO, ERROR, and TRACE logs
resource "aws_cloudwatch_log_delivery_source" "info_logs" {
  for_each     = local.buses
  name         = "eventbus-src-${each.value.name}-info-logs"
  log_type     = "INFO_LOGS"
  resource_arn = aws_cloudwatch_event_bus.this[each.key].arn
}

resource "aws_cloudwatch_log_delivery_source" "error_logs" {
  for_each     = local.buses
  name         = "eventbus-src-${each.value.name}-error-logs"
  log_type     = "ERROR_LOGS"
  resource_arn = aws_cloudwatch_event_bus.this[each.key].arn
}

resource "aws_cloudwatch_log_delivery_source" "trace_logs" {
  for_each     = local.buses
  name         = "eventbus-src-${each.value.name}-trace-logs"
  log_type     = "TRACE_LOGS"
  resource_arn = aws_cloudwatch_event_bus.this[each.key].arn
}

data "aws_iam_policy_document" "logs" {
  for_each = local.buses
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.this[each.key].arn}:log-stream:*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        aws_cloudwatch_log_delivery_source.info_logs[each.key].arn,
        aws_cloudwatch_log_delivery_source.error_logs[each.key].arn,
        aws_cloudwatch_log_delivery_source.trace_logs[each.key].arn
      ]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  for_each        = local.buses
  policy_document = data.aws_iam_policy_document.logs[each.key].json
  policy_name     = "AWSLogDeliveryWrite-${each.value.name}"
}

resource "aws_cloudwatch_log_delivery_destination" "logs" {
  for_each = local.buses
  name     = "event-dlvr-dst-${each.value.name}"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.this[each.key].arn
  }
}

resource "aws_cloudwatch_log_delivery" "logs_info_logs" {
  for_each                 = local.buses
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.logs[each.key].arn
  delivery_source_name     = aws_cloudwatch_log_delivery_source.info_logs[each.key].name
}

resource "aws_cloudwatch_log_delivery" "logs_error_logs" {
  for_each                 = local.buses
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.logs[each.key].arn
  delivery_source_name     = aws_cloudwatch_log_delivery_source.error_logs[each.key].name
  depends_on = [
    aws_cloudwatch_log_delivery.logs_info_logs
  ]
}

resource "aws_cloudwatch_log_delivery" "logs_trace_logs" {
  for_each                 = local.buses
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.logs[each.key].arn
  delivery_source_name     = aws_cloudwatch_log_delivery_source.trace_logs[each.key].name
  depends_on = [
    aws_cloudwatch_log_delivery.logs_error_logs
  ]
}