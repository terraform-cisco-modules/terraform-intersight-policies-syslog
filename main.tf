#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  name = var.organization
}

#____________________________________________________________
#
# Intersight UCS Domain Profile(s) Data Source
# GUI Location: Profiles > UCS Domain Profiles > {Name}
#____________________________________________________________

data "intersight_fabric_switch_profile" "profiles" {
  for_each = { for v in var.profiles : v => v if length(var.profiles) > 0 }
  name     = each.value
}


#____________________________________________________________
#
# Intersight UCS Server Profile(s) Data Source
# GUI Location: Profiles > UCS Server Profiles > {Name}
#____________________________________________________________

data "intersight_server_profile" "profiles" {
  for_each = { for v in local.profiles : v.name => v if v.object_type == "server.Profile" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight UCS Server Profile Template(s) Data Source
# GUI Location: Templates > UCS Server Profile Templates > {Name}
#__________________________________________________________________

data "intersight_server_profile_template" "templates" {
  for_each = { for v in local.profiles : v.name => v if v.object_type == "server.ProfileTemplate" }
  name     = each.value.name
}


#__________________________________________________________________
#
# Intersight Syslog Policy
# GUI Location: Policies > Create Policy > Syslog
#__________________________________________________________________

locals {
  profiles = {
    for v in var.profiles : v.name => {
      name        = v.name
      object_type = v.object_type != null ? v.object_type : "server.Profile"
    }
  }
}

resource "intersight_syslog_policy" "syslog" {
  depends_on = [
    data.intersight_fabric_switch_profile.profiles,
    data.intersight_server_profile.profiles,
    data.intersight_server_profile_template.templates,
    data.intersight_organization_organization.org_moid
  ]
  description = var.description != "" ? var.description : "${var.name} Syslog Policy."
  name        = var.name
  local_clients {
    min_severity = var.local_min_severity
    object_type  = "syslog.LocalFileLoggingClient"
  }
  organization {
    moid        = data.intersight_organization_organization.org_moid.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "profiles" {
    for_each = local.profiles
    content {
      moid = length(regexall("fabric.SwitchProfile", profiles.value.object_type)
        ) > 0 ? data.intersight_fabric_switch_profile.profiles[profiles.value.name].results[0
        ].moid : length(regexall("server.ProfileTemplate", profiles.value.object_type)
        ) > 0 ? data.intersight_server_profile_template.templates[profiles.value.name].results[0
      ].moid : data.intersight_server_profile.profiles[profiles.value.name].results[0].moid
      object_type = profiles.value.object_type
    }
  }
  dynamic "remote_clients" {
    for_each = { for k, v in var.remote_clients : k => v }
    content {
      enabled = length(
        compact([remote_clients.value.enabled])
      ) > 0 ? remote_clients.value.enabled : false
      hostname = remote_clients.value.hostname
      port = length(
        compact([remote_clients.value.port])
      ) > 0 ? remote_clients.value.port : 514
      protocol = length(
        compact([remote_clients.value.protocol])
      ) > 0 ? remote_clients.value.protocol : "udp"
      min_severity = length(
        compact([remote_clients.value.min_severity])
      ) > 0 ? remote_clients.value.min_severity : "warning"
      object_type = "syslog.RemoteLoggingClient"
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
