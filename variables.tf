variable "vdc_org_name" {
  description = "The name of the organization to use."
  type        = string
}

variable "vdc_group_name" {
  description = "The name of the VDC group."
  type        = string
}

variable "vdc_edgegateway_name" {
  description = "The name for the Edge Gateway."
  type        = string
}

variable "app_port_profiles" {
  description = "Map of app port profiles being used in this rule set with their corresponding scopes. These will be looked up with a data ressource."
  type        = map(string)
  default     = {}
}

variable "ip_set_names" {
  description = "List of vcd_nsxt_ip_set names being used in this ruleset. These will be looked up with a data ressource."
  type        = list(string)
  default     = []
}

variable "dynamic_security_group_names" {
  description = "List of vcd_nsxt_dynamic_security_group names being used in this ruleset. These will be looked up with a data ressource."
  type        = list(string)
  default     = []
}

variable "security_group_names" {
  description = "List of vcd_nsxt_security_group names being used in this ruleset. These will be looked up with a data ressource."
  type        = list(string)
  default     = []
}

variable "rules" {
  description = "List of rules to apply."
  type = list(object({
    name                 = string
    direction            = string
    ip_protocol          = string
    action               = string
    enabled              = optional(bool)
    logging              = optional(bool)
    source_ids           = optional(list(string))
    destination_ids      = optional(list(string))
    app_port_profile_ids = optional(list(string))
  }))
  default = []
}
