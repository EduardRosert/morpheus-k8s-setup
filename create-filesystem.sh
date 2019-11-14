#!/bin/bash

# fail fast and show errors
set -eux

# install tools
apt install -y lvm2

# volume setup
pvcreate /dev/vdb

vgcreate k8s /dev/vdb

lvcreate -l 100%VG -n kubelet k8s

mkfs.xfs /dev/k8s/kubelet 

mkdir -p /var/lib/kubelet

cat << EOF >> /etc/fstab
/dev/k8s/kubelet /var/lib/kubelet                       xfs    defaults        1 1
EOF

mount /var/lib/kubelet