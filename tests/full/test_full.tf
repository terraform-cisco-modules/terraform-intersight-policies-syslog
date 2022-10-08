module "main" {
  source       = "../.."
  description  = "${var.name} Syslog Policy."
  name         = var.name
  organization = "terratest"
  remote_clients = [
    {
      enabled  = true
      hostname = "198.18.5.14"
    },
    {
      enabled  = true
      hostname = "198.18.5.15"
    }
  ]
}
