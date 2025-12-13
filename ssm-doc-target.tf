##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "aws_cloudwatch_event_target" "ssm" {
  for_each = {
    for key, target in local.targets : key => target if target.target_type == "ssm"
  }
  rule      = aws_cloudwatch_event_rule.this[each.value.rule_key].name
  target_id = each.value.target_id
  arn       = aws_ssm_document.ssm_doc[each.key].arn
  #role_arn = ""
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


