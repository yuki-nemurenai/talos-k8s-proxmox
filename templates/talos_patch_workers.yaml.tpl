cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true


  discovery:
    enabled: true
    registries:
      service:
        disabled: true
      kubernetes:
        disabled: false

machine:
  install:
    disk: /dev/sda
    wipe: false
  kernel:
    modules:
      - name: br_netfilter
        parameters:
          - nf_conntrack_max=131072
      - name: drbd
        parameters:
          - usermode_helper=disabled
      - name: drbd_transport_tcp

  sysctls:
    net.bridge.bridge-nf-call-ip6tables: "1"
    net.bridge.bridge-nf-call-iptables: "1"
    net.ipv4.ip_forward: "1"