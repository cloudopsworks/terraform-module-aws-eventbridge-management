##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "aws_kms_key" "this" {
  count                   = try(var.encryption.enabled, false) ? 1 : 0
  description             = format("KMS Key for %s EventBridge resources", local.system_name)
  deletion_window_in_days = try(var.encryption.deletion_window, 30)
  enable_key_rotation     = try(var.encryption.key_rotation, true)
  rotation_period_in_days = try(var.encryption.rotation_period, 90)
  multi_region            = try(var.encryption.multi_region, false)
  tags                    = local.all_tags
}

resource "aws_kms_alias" "this" {
  count         = try(var.encryption.enabled, false) ? 1 : 0
  target_key_id = aws_kms_key.this[0].key_id
  name          = format("alias/%s-eventbridge-key", local.system_name_short)
}