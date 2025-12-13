##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  ssm_enabled = contains(local.target_types, "ssm")
}

resource "aws_cloudwatch_event_target" "ssm" {
  for_each = {
    for key, target in local.targets : key => target if target.target_type == "ssm"
  }
  rule           = aws_cloudwatch_event_rule.this[each.value.rule_key].name
  event_bus_name = aws_cloudwatch_event_rule.this[each.value.rule_key].event_bus_name
  target_id      = each.value.target_id
  arn            = aws_ssm_document.ssm_doc[each.key].arn
  role_arn       = aws_iam_role.ssm_lifecycle[0].arn
  dynamic "run_command_targets" {
    for_each = try(each.value.target.run_command_targets, [])
    content {
      key    = run_command_targets.value.key
      values = run_command_targets.value.values
    }
  }
}

resource "aws_ssm_document" "ssm_doc" {
  for_each = {
    for key, target in local.targets : key => target if target.target_type == "ssm"
  }
  name          = format("%s-%s-%s-ssm-doc", each.value.rule_key, each.value.target_id, local.system_name_short)
  document_type = try(each.value.target.document_type, "") != "" ? each.value.target.document_type : "Command"
  content       = try(jsonencode(each.value.target.content), each.value.target.content)
  tags = merge(
    local.all_tags,
    try(each.value.target.tags, {}),
    {
      Name = format("%s-%s-%s-ssm-doc", each.value.rule_key, each.value.target_id, local.system_name_short)
    }
  )
}

### SSM ROLE
data "aws_iam_policy_document" "ssm_lifecycle_trust" {
  count = local.ssm_enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm_lifecycle" {
  count = local.ssm_enabled ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand"
    ]
    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]
    # condition {
    #   test     = "StringEquals"
    #   variable = "ec2:ResourceTag/Terminate"
    #   values   = ["*"]
    # }
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand"
    ]
    resources = [
      for doc in aws_ssm_document.ssm_doc : doc.arn
    ]
  }
}

resource "aws_iam_role" "ssm_lifecycle" {
  count              = local.ssm_enabled ? 1 : 0
  name               = "${local.system_name}-eventbridge-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_lifecycle_trust[0].json
}

resource "aws_iam_role_policy" "ssm_lifecycle" {
  count  = local.ssm_enabled ? 1 : 0
  name   = "SSMLifecycle"
  role   = aws_iam_role.ssm_lifecycle[0].id
  policy = data.aws_iam_policy_document.ssm_lifecycle[0].json
}


