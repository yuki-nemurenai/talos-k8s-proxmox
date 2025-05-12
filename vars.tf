variable "proxmox_virtual_environment" {
    description = "Proxmox Virtual Environment Credentials"
    type = object({
        endpoint   = string
        api_token  = string
        ssh_user   = string
        ssh_password = string
    })
    sensitive = true
}

variable "default_gateway" {
    description = "The IP address of the default gateway of the cluster nodes"
    type = string
}

variable "talos_version" {
    description = "The version of Talos Linux to install"
    type = string
    validation {
        condition = can(regex("^\\d+(\\.\\d+)+", var.talos_version))
        error_message = "Must be a valid (semantic) version number"
    }
}

variable "talos_factory_url" {
    description = "Talos Linux Image Factory"
    type = string
    default = "https://factory.talos.dev"
}

variable "nodes" {
    description = "The nodes configuration"
    type = map(object({
        count = number
        cpu = number
        memory = number
        disk1_size = number
        disk2_size = number
        cloud_init_datastore = string
    }))
}

variable "control_plane_nodes_name" {
    type = string
    default = "controlplane"
}

variable "worker_nodes_name" {
    type = string
    default = "worker"
}

variable "cluster_network_cidr" {
    description = "The CIDR block for the cluster network"
    type = string
    validation {
        condition = can(regex(local.regex_valid_ip_cidrsubnet, var.cluster_network_cidr))
        error_message = "Must be a valid CIDR block"
    }
}


variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "talos.local"
}

variable "prefix" {
    description = "A prefix to provide for the cluster"
    type = string
    default = "k8s"
}

variable "cluster_vip_address" {
    description = "The Kubernetes cluster VIP address"
    type = string
    validation {
        condition = can(regex(local.regex_valid_ip_cidrhost, var.cluster_vip_address))
        error_message = "Must be a valid IP address"
    }
}

variable "cluster_endpoint" {
    description = "The Kubernetes api-server endpoint (based on the cluster VIP address)"
    type = string
    validation {
        condition = can(regex(local.regex_valid_cluster_endpoint, var.cluster_endpoint))
        error_message = "Must be a valid Kubernetes cluster endpoint"
    }
}

variable "kubernetes_version" {
    type = string
    validation {
        condition = can(regex("^\\d+(\\.\\d+)+", var.kubernetes_version))
        error_message = "Must be a valid (semantic) version number"
    }
}

variable "lb_ip_pool_cidr" {
    description = "The CIDR block for the load balancer IP pool"
    type = string
    validation {
        condition = can(regex(local.regex_valid_ip_cidrsubnet, var.lb_ip_pool_cidr))
        error_message = "Must be a valid CIDR block"
    }
}

variable "lb_ip_dedicated" {
    description = "The dedicated load balancer IP address"
    type = string
    validation {
        condition = can(regex(local.regex_valid_ip_cidrhost, var.lb_ip_dedicated))
        error_message = "Must be a valid IP address"
    }
}

variable "cluster_control_plane_node_first_ip" {
    description = "The first IP number for the control plane nodes"
    type = string
    validation {
        condition = can(regex(local.regex_valid_ip_cidrhost, var.cluster_control_plane_node_first_ip))
        error_message = "Must be a valid IP address"
    }
}

variable "cluster_worker_node_first_ip" {
    description = "The first IP number for the worker nodes"
    type = string
    validation {
        condition = can(regex(local.regex_valid_ip_cidrhost, var.cluster_worker_node_first_ip))
        error_message = "Must be a valid IP address"
    }
}

variable "nodes_and_storages_distribution" {
  description = "Distribution by nodes and storage facilities"
  type = list(object({
    node       = string
    datastore  = string
  }))
  default = [
    { node = "pve", datastore = "local-lvm" },
  ]
}

variable "github" {
    description = "GitHub Credentials for Flux bootstrap"
    type = object({
        repository_url = string
        username = string
        token = string
    })
    sensitive = true
}

variable "flux" {
    description = "The Flux configuration"
    type = object({
       branch = string
       path = string
    })
}




