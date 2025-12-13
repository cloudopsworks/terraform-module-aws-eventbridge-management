##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "encryption" {
  description = "Enable encryption for EventBridge resources."
  type        = any
  default     = {}
  nullable    = false
}

variable "event_buses" {
  description = "A map of EventBridge bus configurations."
  type        = any
  default     = {}
  nullable    = false
}

variable "configs" {
  description = "A map of EventBridge Rules & Target configurations."
  type        = any
  default     = {}
  nullable    = false
}