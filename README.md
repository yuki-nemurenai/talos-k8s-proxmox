# Talos Kubernetes Cluster on Proxmox with Terraform

## Description

This project is designed for automated deployment of a Kubernetes cluster based on Talos Linux in a Proxmox virtual environment using Terraform. It includes automatic installation of Cilium (CNI) and Flux (GitOps), as well as support for custom Talos extensions via schematics.


## Requirements

- Proxmox VE with API access
- Terraform
- GitHub repository for Flux (optional)

## Quick Start

1. Create `secret.tfvars` and fill in your values:
   - Proxmox access credentials
   - Proxmox VMs parameters
   - Network parameters 
   - Talos and Kubernetes versions
   - GitHub token and Flux parameters (if used)
2. Check and, if necessary, adjust variables in `vars.tf`.
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the deployment plan:
   ```bash
   terraform plan -var-file=secret.tfvars
   ```
5. Apply the changes:
   ```bash
   terraform apply -var-file=secret.tfvars
   ```
6. After completion, get the kubeconfig and the talosconfig:
    ```hcl
    terraform output -raw kubeconfig > $HOME/kubeconfig
    terraform output -raw talosconfig > $HOME/talosconfig
    ```

## secret.tfvars reference

```hcl
proxmox_virtual_environment = {
    endpoint = "https://pve-01:8006/"
    api_token = "your-proxmox-api-token"
    ssh_user = "your-ssh-user"
    ssh_password = "your-ssh-password"
}
default_gateway = "10.0.7.30"
cluster_network_cidr = "10.0.7.0/27"
cluster_control_plane_node_first_ip = "10.0.7.1"
cluster_worker_node_first_ip = "10.0.7.10"
talos_version = "1.9.5"
cluster_name = "proxmox.local"
cluster_vip_address = "10.0.7.20"
kubernetes_version = "1.32.3"
lb_ip_pool_cidr = "10.0.7.0/27"
lb_ip_dedicated = "10.0.7.29"
cluster_endpoint = "https://10.0.7.20:6443"
nodes_and_storages_distribution = [
    { node = "pve-01", datastore = "local-lvm" }
    { node = "pve-02", datastore = "pve_02_zfs_pool" }
]
github = {
    repository_url = "your-flux-repo"
    username = "your-github-user"
    token = "your-github-pat-token"
}
flux = {
    branch = "main"
    path = "clusters/proxmox-local"
}
nodes = {
    controlplane = {
        count = 1
        cpu = 2
        memory = 4096
        disk1_size = 20
        disk2_size = 50
        cloud_init_datastore = "pve_nfs_datastore"
    }
    worker = {
        count = 1
        cpu = 4
        memory = 12288   
        disk1_size = 20
        disk2_size = 50
        cloud_init_datastore = "pve_nfs_datastore"
    }
}
```

## Security

- Do not add files with secrets (`*.tfvars`, `kubeconfig`, keys) to git — they are already listed in `.gitignore`.

## License

[MIT](LICENSE) 