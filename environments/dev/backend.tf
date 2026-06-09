terraform {
  cloud {
    organization = "alexcrh"
    workspaces {
      name = "enterprise-dev"
    }
  }
}
