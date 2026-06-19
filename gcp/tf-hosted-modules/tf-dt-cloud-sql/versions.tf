terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.22, < 8"
    }
    # The upstream sql-db module uses google-beta; the consuming environment
    # must configure a google-beta provider (project/region) alongside google.
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 7.22, < 8"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
