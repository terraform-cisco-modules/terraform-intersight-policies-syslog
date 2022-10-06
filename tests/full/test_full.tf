terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
}

# Setup provider, variables and outputs
provider "intersight" {
  apikey    = var.intersight_keyid
  secretkey = file(var.intersight_secretkeyfile)
  endpoint  = var.intersight_endpoint
}

variable "intersight_keyid" {}
variable "intersight_secretkeyfile" {}
variable "intersight_endpoint" {
  default = "intersight.com"
}
variable "name" {}

output "moid" {
  value = module.main.moid
}

# This is the module under test
module "main" {
  source       = "../.."
  description  = "${var.name} Syslog Policy."
  name         = var.name
  organization = "terratest"
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
