#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  for_each = {
    for v in [var.organization] : v => v if length(
      regexall("[[:xdigit:]]{24}", var.organization)
    ) == 0
  }
  name = each.value
}

#____________________________________________________________
#
# Intersight UCS Domain Profile(s) Data Source
# GUI Location: Profiles > UCS Domain Profiles > {Name}
#____________________________________________________________

data "intersight_fabric_switch_profile" "profiles" {
  for_each = {
    for v in var.profiles : v.name => v if v.object_type == "fabric.SwitchProfile" && length(
      regexall("[[:xdigit:]]{24}", v.name)
    ) == 0
  }
  name = each.value.name
}


#____________________________________________________________
#
# Intersight UCS Server Profile(s) Data Source
# GUI Location: Profiles > UCS Server Profiles > {Name}
#____________________________________________________________

data "intersight_server_profile" "profiles" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.Profile" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight UCS Server Profile Template(s) Data Source
# GUI Location: Templates > UCS Server Profile Templates > {Name}
#__________________________________________________________________

data "intersight_server_profile_template" "templates" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.ProfileTemplate" }
  name     = each.value.name
}


#__________________________________________________________________
#
# Intersight Syslog Policy
# GUI Location: Policies > Create Policy > Syslog
#__________________________________________________________________

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
    moid = length(
      regexall("[[:xdigit:]]{24}", var.organization)
      ) > 0 ? var.organization : data.intersight_organization_organization.org_moid[
      var.organization].results[0
    ].moid
    object_type = "organization.Organization"
  }
  dynamic "profiles" {
    for_each = { for v in var.profiles : v.name => v }
    content {
      moid = length(regexall("fabric.SwitchProfile", profiles.value.object_type)
        ) > 0 ? length(
        regexall("[[:xdigit:]]{24}", profiles.value.name)
        ) > 0 ? profiles.value.name : data.intersight_fabric_switch_profile.profiles[profiles.value.name].results[0
        ].moid : length(regexall("server.ProfileTemplate", profiles.value.object_type)
        ) > 0 ? data.intersight_server_profile_template.templates[profiles.value.name].results[0
      ].moid : data.intersight_server_profile.profiles[profiles.value.name].results[0].moid
      object_type = profiles.value.object_type
    }
  }
  dynamic "remote_clients" {
    for_each = { for k, v in var.remote_clients : k => v }
    content {
      enabled      = remote_clients.value.enabled
      hostname     = remote_clients.value.hostname
      port         = remote_clients.value.port
      protocol     = remote_clients.value.protocol
      min_severity = remote_clients.value.min_severity
      object_type  = "syslog.RemoteLoggingClient"
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
