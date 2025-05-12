resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for node in local.control_plane_nodes : node.address]
}


data "talos_machine_configuration" "talos_controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version      = "v${var.talos_version}"
  kubernetes_version = "v${var.kubernetes_version}"
  docs               = false
  examples           = false
  config_patches = [
    templatefile("${path.module}/templates/talos_patch_controlplane.yaml.tpl",
      {
        talos_cluster_vip_address = var.cluster_vip_address
      }
    )
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on                  = [ proxmox_virtual_environment_vm.controlplane ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  count                       = var.nodes.controlplane.count
  endpoint                    = local.control_plane_nodes[count.index].address
  node                        = local.control_plane_nodes[count.index].address
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version      = "v${var.talos_version}"
  kubernetes_version = "v${var.kubernetes_version}"
  docs               = false
  examples           = false
  config_patches = [
    templatefile("${path.module}/templates/talos_patch_workers.yaml.tpl",
      {
        talos_cluster_vip_address = var.cluster_vip_address
      }
    )
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on                  = [ proxmox_virtual_environment_vm.worker ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  count                       = var.nodes.worker.count
  endpoint                    = local.worker_nodes[count.index].address
  node                        = local.worker_nodes[count.index].address
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [ talos_machine_configuration_apply.controlplane ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.control_plane_nodes[0].address
  endpoint            = local.control_plane_nodes[0].address
}


data "talos_cluster_health" "this" {
  depends_on           = [ talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker ]
  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes  = [ for node in local.control_plane_nodes : node.address ]
  worker_nodes         = [ for node in local.worker_nodes : node.address ]
  endpoints            = data.talos_client_configuration.this.endpoints
  skip_kubernetes_checks = true
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [ talos_machine_bootstrap.this ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.control_plane_nodes[0].address
}

output "talosconfig" {
  value = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}