terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.75.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.7.1"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.5"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.17.0"
    }
    flux = {
      source = "fluxcd/flux"
      version = "1.5.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_virtual_environment.endpoint
  api_token = var.proxmox_virtual_environment.api_token
  ssh {
    agent = true
    username = var.proxmox_virtual_environment.ssh_user
    password = var.proxmox_virtual_environment.ssh_password
  }
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

provider "flux" {
  kubernetes = {
    config_path = local_file.kubeconfig.filename
  }
  git = {
    url = var.github.repository_url
    branch = var.flux.branch
    http = {
      username = var.github.username
      password = var.github.token
    }
  }
}