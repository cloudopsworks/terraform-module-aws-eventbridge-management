## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.55.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_bus.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_delivery.logs_error_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery) | resource |
| [aws_cloudwatch_log_delivery.logs_info_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery) | resource |
| [aws_cloudwatch_log_delivery.logs_trace_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery) | resource |
| [aws_cloudwatch_log_delivery_destination.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_destination) | resource |
| [aws_cloudwatch_log_delivery_source.error_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_source) | resource |
| [aws_cloudwatch_log_delivery_source.info_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_source) | resource |
| [aws_cloudwatch_log_delivery_source.trace_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_source) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_iam_role.ssm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ssm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ssm_lifecycle_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_scheduler_schedule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule_group) | resource |
| [aws_ssm_document.ssm_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_lifecycle_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_lifecycle_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configs"></a> [configs](#input\_configs) | A map of EventBridge Rules & Target configurations. | `any` | `{}` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Enable encryption for EventBridge resources. | `any` | `{}` | no |
| <a name="input_event_buses"></a> [event\_buses](#input\_event\_buses) | A map of EventBridge bus configurations. | `any` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to the resources | `map(string)` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Is this a hub or spoke configuration? | `bool` | `false` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization details | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_scheduler_groups"></a> [scheduler\_groups](#input\_scheduler\_groups) | A map of EventBridge Scheduler schedule group configurations. | `any` | `{}` | no |
| <a name="input_schedulers"></a> [schedulers](#input\_schedulers) | A map of EventBridge Scheduler schedule configurations. | `any` | `{}` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | Spoke ID Number, must be a 3 digit number | `string` | `"001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_bus_arns"></a> [event\_bus\_arns](#output\_event\_bus\_arns) | ARNs of EventBridge event buses created by this module, keyed by event\_buses key. |
| <a name="output_event_bus_names"></a> [event\_bus\_names](#output\_event\_bus\_names) | Names of EventBridge event buses created by this module, keyed by event\_buses key. |
| <a name="output_event_rule_arns"></a> [event\_rule\_arns](#output\_event\_rule\_arns) | ARNs of EventBridge rules created by this module, keyed by configs key. |
| <a name="output_event_rule_names"></a> [event\_rule\_names](#output\_event\_rule\_names) | Names of EventBridge rules created by this module, keyed by configs key. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the module-managed KMS key when encryption.enabled is true; null when no module-managed key is created. |
| <a name="output_scheduler_group_arns"></a> [scheduler\_group\_arns](#output\_scheduler\_group\_arns) | ARNs of EventBridge Scheduler schedule groups created by this module, keyed by scheduler\_groups key. |
| <a name="output_scheduler_group_names"></a> [scheduler\_group\_names](#output\_scheduler\_group\_names) | Names of EventBridge Scheduler schedule groups created by this module, keyed by scheduler\_groups key. |
| <a name="output_scheduler_schedule_arns"></a> [scheduler\_schedule\_arns](#output\_scheduler\_schedule\_arns) | ARNs of EventBridge Scheduler schedules created by this module, keyed by schedulers key. |
| <a name="output_scheduler_schedule_names"></a> [scheduler\_schedule\_names](#output\_scheduler\_schedule\_names) | Names of EventBridge Scheduler schedules created by this module, keyed by schedulers key. |
| <a name="output_ssm_document_arns"></a> [ssm\_document\_arns](#output\_ssm\_document\_arns) | ARNs of SSM documents created for EventBridge SSM targets, keyed by rule and target. |
| <a name="output_ssm_document_names"></a> [ssm\_document\_names](#output\_ssm\_document\_names) | Names of SSM documents created for EventBridge SSM targets, keyed by rule and target. |
