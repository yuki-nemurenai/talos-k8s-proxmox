resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = var.nodes.controlplane.cloud_init_datastore != "" ? var.nodes.controlplane.cloud_init_datastore : var.nodes.worker.cloud_init_datastore
  node_name               = var.nodes_and_storages_distribution[0].node
  file_name               = "talos-${var.talos_version}-nocloud-amd64.img"
  url                     = "${var.talos_factory_url}/image/${local.talos_schematic_id}/v${var.talos_version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "controlplane" {
  count       = var.nodes.controlplane.count
  name        = "${var.prefix}-${local.control_plane_nodes[count.index].name}"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]
  node_name   = var.nodes_and_storages_distribution[count.index % length(var.nodes_and_storages_distribution)].node
  stop_on_destroy = true
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  cpu {
    cores = var.nodes.controlplane.cpu
    type = "host"
  }

  memory {
    dedicated = var.nodes.controlplane.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = var.nodes_and_storages_distribution[count.index % length(var.nodes_and_storages_distribution)].datastore
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.nodes.controlplane.disk1_size
  }

  disk {
    datastore_id = var.nodes_and_storages_distribution[count.index % length(var.nodes_and_storages_distribution)].datastore
    file_id      = ""
    file_format  = "raw"
    interface    = "scsi1"
    size         = var.nodes.controlplane.disk2_size
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = var.nodes.controlplane.cloud_init_datastore
    ip_config {
      ipv4 {
        address = "${local.control_plane_nodes[count.index].address}/20"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "worker" {
  count = var.nodes.worker.count
  depends_on = [ proxmox_virtual_environment_vm.controlplane ]
  name        = "${var.prefix}-${local.worker_nodes[count.index].name}"
  description = "Managed by Terraform"
  tags        = ["terraform", "kubernetes"]
  node_name   = var.nodes_and_storages_distribution[count.index % length(var.nodes_and_storages_distribution)].node
  stop_on_destroy = true
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  cpu {
    cores = var.nodes.worker.cpu
    type = "host"
  }

  memory {
    dedicated = var.nodes.worker.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = var.nodes_and_storages_distribution[count.index % length(var.nodes_and_storages_distribution)].datastore
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.nodes.worker.disk1_size
  }

  disk {
    datastore_id = var.nodes_and_storages_distribution[count.index % length(var.nodes_and_storages_distribution)].datastore
    file_id      = ""
    file_format  = "raw"
    interface    = "scsi1"
    size         = var.nodes.worker.disk2_size
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = var.nodes.worker.cloud_init_datastore
    ip_config {
      ipv4 {
        address = "${local.worker_nodes[count.index].address}/20"
        gateway = var.default_gateway
      }
    }
  }
}