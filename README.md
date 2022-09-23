<!-- BEGIN_TF_DOCS -->
# Terraform Intersight Policies - Syslog
Manages Intersight Syslog Policies

Location in GUI:
`Policies` » `Create Policy` » `Syslog`

## Example

### main.tf
```hcl
module "syslog_policy" {
  source  = "terraform-cisco-modules/policies-syslog/intersight"
  version = ">= 1.0.1"

  description  = "default Syslog Policy."
  name         = "default"
  organization = "default"
  remote_clients = [
    {
      enabled  = true
      hostname = "198.18.1.21"
    },
    {
      enabled  = true
      hostname = "198.18.1.22"
    }
  ]
}
```

### variables.tf
```hcl
variable "apikey" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
}

variable "endpoint" {
  default     = "https://intersight.com"
  description = "Intersight URL."
  type        = string
}

variable "secretkey" {
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}
```

### versions.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = var.secretkey
}
```

### Environment Variables

Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey="<secret-key-file-location>""
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Intersight URL. | `string` | `"https://intersight.com"` | no |
| <a name="input_secretkey"></a> [secretkey](#input\_secretkey) | Intersight Secret Key. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_local_min_severity"></a> [local\_min\_severity](#input\_local\_min\_severity) | Lowest level of messages to be included in the local log.<br>  - warning - Use logging level warning for logs classified as warning.<br>  - emergency - Use logging level emergency for logs classified as emergency.<br>  - alert - Use logging level alert for logs classified as alert.<br>  - critical - Use logging level critical for logs classified as critical.<br>  - error - Use logging level error for logs classified as error.<br>  - notice - Use logging level notice for logs classified as notice.<br>  - informational - Use logging level informational for logs classified as informational.<br>  - debug - Use logging level debug for logs classified as debug. | `string` | `"warning"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | Map of Profiles to Assign to the Policy.<br>* name - Managed Object Identifier for the Managed Resource.<br>* object\_type - Object Type to Assign in the Profile Configuration.<br>  - fabric.SwitchProfile - For UCS Domain Switch Profiles.<br>  - server.Profile - For UCS Server Profiles.<br>  - server.ProfileTemplate - For UCS Server Profile Templates. | <pre>list(object(<br>    {<br>      name        = string<br>      object_type = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_remote_clients"></a> [remote\_clients](#input\_remote\_clients) | NOTE: You can configure up to 2 remote syslog servers.<br>* enabled: (default is false) - Enables/disables remote logging for the endpoint If enabled, log messages will be sent to the syslog server mentioned in the Hostname/IP Address field.<br>* hostname: (required) - Hostname or IP Address of the syslog server where log should be stored.<br>* min\_severity: (default is warning) - Lowest level of messages to be included in the local log.<br>  - warning - Use logging level warning for logs classified as warning.<br>  - emergency - Use logging level emergency for logs classified as emergency.<br>  - alert - Use logging level alert for logs classified as alert.<br>  - critical - Use logging level critical for logs classified as critical.<br>  - error - Use logging level error for logs classified as error.<br>  - notice - Use logging level notice for logs classified as notice.<br>  - informational - Use logging level informational for logs classified as informational.<br>  - debug - Use logging level debug for logs classified as debug.<br>* port: (default is 514) - Range 1-65535.  Port number used for logging on syslog server.<br>* protocol: (default is udp) - Transport layer protocol for transmission of log messages to syslog server.<br>  - tcp - Use Transmission Control Protocol (TCP) for syslog remote server connection.<br>  - udp - Use User Datagram Protocol (UDP) for syslog remote server connection. | <pre>list(object(<br>    {<br>      enabled      = optional(bool)<br>      hostname     = string<br>      min_severity = optional(string)<br>      port         = optional(number)<br>      protocol     = optional(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | Syslog Policy Managed Object ID (moid). |
## Resources

| Name | Type |
|------|------|
| [intersight_syslog_policy.syslog](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/syslog_policy) | resource |
| [intersight_fabric_switch_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_switch_profile) | data source |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
| [intersight_server_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile) | data source |
| [intersight_server_profile_template.templates](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile_template) | data source |
<!-- END_TF_DOCS -->