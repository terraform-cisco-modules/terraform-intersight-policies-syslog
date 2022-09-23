terraform {
  experiments = [module_variable_optional_attrs]
}

#____________________________________________________________
#
# Syslog Policy Variables Section.
#____________________________________________________________

variable "description" {
  default     = ""
  description = "Description for the Policy."
  type        = string
}

variable "name" {
  default     = "default"
  description = "Name for the Policy."
  type        = string
}

variable "local_min_severity" {
  default     = "warning"
  description = <<-EOT
    Lowest level of messages to be included in the local log.
      - warning - Use logging level warning for logs classified as warning.
      - emergency - Use logging level emergency for logs classified as emergency.
      - alert - Use logging level alert for logs classified as alert.
      - critical - Use logging level critical for logs classified as critical.
      - error - Use logging level error for logs classified as error.
      - notice - Use logging level notice for logs classified as notice.
      - informational - Use logging level informational for logs classified as informational.
      - debug - Use logging level debug for logs classified as debug.
  EOT
  type        = string
}


variable "organization" {
  default     = "default"
  description = "Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/."
  type        = string
}

variable "profiles" {
  default     = []
  description = <<-EOT
    List of Profiles to Assign to the Policy.
    * name - Name of the Profile to Assign.
    * object_type - Object Type to Assign in the Profile Configuration.
      - fabric.SwitchProfile - For UCS Domain Switch Profiles.
      - server.Profile - For UCS Server Profiles.
      - server.ProfileTemplate - For UCS Server Profile Templates.
  EOT
  type = list(object(
    {
      name        = string
      object_type = string
    }
  ))
}

variable "remote_clients" {
  default     = []
  description = <<-EOT
    NOTE: You can configure up to 2 remote syslog servers.
    * enabled: (default is false) - Enables/disables remote logging for the endpoint If enabled, log messages will be sent to the syslog server mentioned in the Hostname/IP Address field.
    * hostname: (required) - Hostname or IP Address of the syslog server where log should be stored.
    * min_severity: (default is warning) - Lowest level of messages to be included in the local log.
      - warning - Use logging level warning for logs classified as warning.
      - emergency - Use logging level emergency for logs classified as emergency.
      - alert - Use logging level alert for logs classified as alert.
      - critical - Use logging level critical for logs classified as critical.
      - error - Use logging level error for logs classified as error.
      - notice - Use logging level notice for logs classified as notice.
      - informational - Use logging level informational for logs classified as informational.
      - debug - Use logging level debug for logs classified as debug.
    * port: (default is 514) - Range 1-65535.  Port number used for logging on syslog server.
    * protocol: (default is udp) - Transport layer protocol for transmission of log messages to syslog server.
      - tcp - Use Transmission Control Protocol (TCP) for syslog remote server connection.
      - udp - Use User Datagram Protocol (UDP) for syslog remote server connection.
  EOT
  type = list(object(
    {
      enabled      = optional(bool)
      hostname     = string
      min_severity = optional(string)
      port         = optional(number)
      protocol     = optional(string)
    }
  ))
}

variable "tags" {
  default     = []
  description = "List of Tag Attributes to Assign to the Policy."
  type        = list(map(string))
}
