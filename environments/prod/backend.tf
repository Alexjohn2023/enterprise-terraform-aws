terraform {
  cloud {
    organization = "alexcrh"
    workspaces {
      name = "enterprise-prod"
    }
  }
}
