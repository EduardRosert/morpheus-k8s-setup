#!/bin/bash

# fail fast and show errors
set -eux

# Morpheus default env for instance
# IP_INTERNAL

kubeadm_token=y5g1m2.uckqmkuewh5809iz
hostname=$HOSTNAME
discovery_timeout=30m0s
kube_api_internal_address=$KUBE_API_ADDRESS

kubeadm_conf=/root/kubeadm.conf
cat > $kubeadm_conf <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: $kube_api_internal_address:443
    token: $kubeadm_token
    unsafeSkipCAVerification: true
  timeout: $discovery_timeout
  tlsBootstrapToken: $kubeadm_token
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: $hostname
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF

# Initialise Kubernetes components.
kubeadm join \
	-v 3 \
	--config $kubeadm_conf