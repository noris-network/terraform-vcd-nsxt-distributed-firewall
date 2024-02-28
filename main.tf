data "vcd_vdc_group" "vdc_group" {
  name = var.vdc_group_name
}

data "vcd_nsxt_edgegateway" "nsxt_edgegateway" {
  org      = var.vdc_org_name
  owner_id = data.vcd_vdc_group.vdc_group.id
  name     = var.vdc_edgegateway_name
}

data "vcd_nsxt_app_port_profile" "nsxt_app_port_profile" {
  for_each = var.app_port_profiles
  name     = each.key
  scope    = each.value
}

data "vcd_nsxt_ip_set" "nsxt_ip_set" {
  for_each        = toset(var.ip_set_names)
  edge_gateway_id = data.vcd_nsxt_edgegateway.nsxt_edgegateway.id
  name            = each.value
}

data "vcd_nsxt_dynamic_security_group" "nsxt_dynamic_security_groups" {
  for_each     = toset(var.dynamic_security_group_names)
  vdc_group_id = data.vcd_vdc_group.vdc_group.id
  name         = each.value
}

data "vcd_nsxt_security_group" "nsxt_security_groups" {
  for_each        = toset(var.security_group_names)
  edge_gateway_id = data.vcd_nsxt_edgegateway.nsxt_edgegateway.id
  name            = each.value
}

resource "vcd_nsxt_distributed_firewall" "nsxt_distributed_firewall" {
  vdc_group_id = data.vcd_vdc_group.vdc_group.id

  dynamic "rule" {
    for_each = var.rules
    content {
      name                 = rule.value["name"]
      direction            = rule.value["direction"]
      ip_protocol          = rule.value["ip_protocol"]
      action               = rule.value["action"]
      enabled              = try(rule.value["enabled"], true)
      logging              = try(rule.value["logging"], false)
      source_ids           = try(length(rule.value["source_ids"]), 0) > 0 ? [for id in rule.value["source_ids"] : try(data.vcd_nsxt_security_group.nsxt_security_groups[id].id, try(data.vcd_nsxt_dynamic_security_group.nsxt_dynamic_security_groups[id].id, data.vcd_nsxt_ip_set.nsxt_ip_set[id].id)) if id != null && id != ""] : null
      destination_ids      = try(length(rule.value["destination_ids"]), 0) > 0 ? [for id in rule.value["destination_ids"] : try(data.vcd_nsxt_security_group.nsxt_security_groups[id].id, try(data.vcd_nsxt_dynamic_security_group.nsxt_dynamic_security_groups[id].id, data.vcd_nsxt_ip_set.nsxt_ip_set[id].id)) if id != null && id != ""] : null
      app_port_profile_ids = try(length(rule.value["app_port_profile_ids"]), 0) > 0 ? [for name in rule.value["app_port_profile_ids"] : data.vcd_nsxt_app_port_profile.nsxt_app_port_profile[name].id if name != null && name != ""] : null
    }
  }

  # This prevents destruction and recreation of the whole rule set if an ip_set is added by the terraform-vcd-nsxt-ip-set module
  # or an application port profile by the terraform-vcd-nsxt-app-port-profile module
  lifecycle {
    ignore_changes = [vdc_group_id]
  }
}
