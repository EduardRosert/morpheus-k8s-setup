#!/bin/bash

# fail fast and show errors
set -eux

# Morpheus default env for instance
# IP_INTERNAL

kubeadm_token=y5g1m2.uckqmkuewh5809iz
ip_address=$IP_INTERNAL
hostname=$HOSTNAME
kube_api_cert_extra_sans=$IP_INTERNAL,127.0.0.1,localhost
control_plane_timeout=30m0s
cluster_name=morpheus-k8s-cluster
kube_api_internal_address=$IP_INTERNAL
kubernetes_version=$(kubeadm version -o short)
pods_cidr=10.200.0.0/16
services_cidr=10.96.0.0/12

kubeadm_conf=/root/kubeadm.conf
cat > $kubeadm_conf <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: $kubeadm_token
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
localAPIEndpoint:
  advertiseAddress: $ip_address
  bindPort: 443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: $hostname
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  certSANs: [$kube_api_cert_extra_sans]
  timeoutForControlPlane: $control_plane_timeout
  extraArgs:
    authorization-mode: Node,RBAC
certificatesDir: /etc/kubernetes/pki
clusterName: $cluster_name
controlPlaneEndpoint: $kube_api_internal_address
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kubernetesVersion: $kubernetes_version
networking:
  dnsDomain: cluster.local
  podSubnet: $pods_cidr
  serviceSubnet: $services_cidr
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF

until kubeadm init \
	  -v 3 \
	  --ignore-preflight-errors all \
	  --config $kubeadm_conf ; do
  echo "kubeadm init crashed, retrying ..."
  sleep 1
done

# Ensure `kubectl` may contact the apiserver.

for d in /root ; do
  mkdir -p ${d}/.kube
  cp /etc/kubernetes/admin.conf ${d}/.kube/config
done

chown -R root: /root/.kube

export KUBECONFIG=/root/.kube/config

# Set up CNI.

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"