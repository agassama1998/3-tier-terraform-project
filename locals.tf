#map of string of local variables to be used as tags in all resources.
locals {
  project_tags = {
    contact      = "devops@apci.com"
    application  = "Jupiter"
    project      = "APCI"
    environment  = "${terraform.workspace}" # refers to your current workspace (default, dev, prod, etc)
    creationTime = timestamp()
  }
}