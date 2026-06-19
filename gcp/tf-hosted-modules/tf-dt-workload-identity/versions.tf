terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.17, < 8"
    }
    # The submodule manages a kubernetes_service_account, so the consuming
    # environment must configure a kubernetes provider pointed at the cluster.
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20, < 4"
    }
  }
}
