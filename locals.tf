locals {
  regex_valid_ip_cidrhost = "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
  regex_valid_ip_cidrsubnet = "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(250-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9])$"
  regex_valid_cluster_endpoint = "^https:\\/\\/(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?):6443$"
  
  control_plane_octets = split(".", var.cluster_control_plane_node_first_ip)
  worker_octets        = split(".", var.cluster_worker_node_first_ip)
  
  control_plane_start_num = (tonumber(local.control_plane_octets[2]) * 256) + tonumber(local.control_plane_octets[3])
  worker_start_num        = (tonumber(local.worker_octets[2]) * 256) + tonumber(local.worker_octets[3])

  base_network_octets = split(".", cidrhost(var.cluster_network_cidr, 0))
  base_network_num    = (tonumber(local.base_network_octets[2]) * 256) + tonumber(local.base_network_octets[3])

  control_plane_nodes = [
    for i in range(var.nodes.controlplane.count) : {
      name    = "${var.control_plane_nodes_name}-${i}"
      address = cidrhost(var.cluster_network_cidr, local.control_plane_start_num - local.base_network_num + i)
    }
  ]
  worker_nodes = [
    for i in range(var.nodes.worker.count) : {
      name    = "${var.worker_nodes_name}-${i}"
      address = cidrhost(var.cluster_network_cidr, local.worker_start_num - local.base_network_num + i)
    }
  ]

  talos_schematic_id = jsondecode(data.http.talos_schematic_id.response_body)["id"]
}