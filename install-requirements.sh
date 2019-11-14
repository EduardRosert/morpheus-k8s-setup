#!/bin/bash

# fail fast and show errors
set -eux

# from https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common -y

# install gpg-agent
apt-get install gpg-agent -y

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
apt-get update -y && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu -y

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

## Installing kubeadm, kubelet and kubectl
sudo apt-get update -y && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# enable module at boot
cat <<EOF > /etc/modules-load.d/br_netfilter.conf
# Load br_netfilter at boot
br_netfilter
EOF

# start module now
modprobe br_netfilter


#Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config, e.g.
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

# Load IPVS modules.
cat > /etc/modules-load.d/kubernetes.conf <<EOF
ip_vs_rr
ip_vs_wrr
ip_vs_sh
ip_vs
nf_conntrack_ipv4
EOF

modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe ip_vs
modprobe nf_conntrack_ipv4


# install some tools
apt-get install -y \
    tcpdump \
    bridge-utils \
    strace \
    ipvsadm
  


# ca of morpheus.ecmwf.int
cat > /usr/local/share/ca-certificates/QuoVadis_Global_SSL_ICA_G3.pem <<EOF
-----BEGIN CERTIFICATE-----
MIIGFzCCA/+gAwIBAgIUftbnnMmtgcTIGT75XUQodw40ExcwDQYJKoZIhvcNAQEL
BQAwSDELMAkGA1UEBhMCQk0xGTAXBgNVBAoTEFF1b1ZhZGlzIExpbWl0ZWQxHjAc
BgNVBAMTFVF1b1ZhZGlzIFJvb3QgQ0EgMiBHMzAeFw0xMjExMDYxNDUwMThaFw0y
MjExMDYxNDUwMThaME0xCzAJBgNVBAYTAkJNMRkwFwYDVQQKExBRdW9WYWRpcyBM
aW1pdGVkMSMwIQYDVQQDExpRdW9WYWRpcyBHbG9iYWwgU1NMIElDQSBHMzCCAiIw
DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANf8Od17be6c6lTGJDhEXpmkTs4y
Q39Rr5VJyBeWCg06nSS71s6xF3sZvKcV0MbXlXCYM2ZX7cNTbJ81gs7uDsKFp+vK
EymiKyEiI2SImOtECNnSg+RVR4np/xz/UlC0yFUisH75cZsJ8T1pkGMfiEouR0EM
7O0uFgoboRfUP582TTWy0F7ynSA6YfGKnKj0OFwZJmGHVkLs1VevWjhj3R1fsPan
H05P5moePFnpQdj1FofoSxUHZ0c7VB+sUimboHm/uHNY1LOsk77qiSuVC5/yrdg3
2EEfP/mxJYT4r/5UiD7VahySzeZHzZ2OibQm2AfgfMN3l57lCM3/WPQBhMAPS1jz
kE+7MjajM2f0aZctimW4Hasrj8AQnfAdHqZehbhtXaAlffNEzCdpNK584oCTVR7N
UR9iZFx83ruTqpo+GcLP/iSYqhM4g7fy45sNhU+IS+ca03zbxTl3TTlkofXunI5B
xxE30eGSQpDZ5+iUJcEOAuVKrlYocFbB3KF45hwcbzPWQ1DcO2jFAapOtQzeS+MZ
yZzT2YseJ8hQHKu8YrXZWwKaNfyl8kFkHUBDICowNEoZvBwRCQp8sgqL6YRZy0uD
JGxmnC2e0BVKSjcIvmq/CRWH7yiTk9eWm73xrsg9iIyD/kwJEnLyIk8tR5V8p/hc
1H2AjDrZH12PsZ45AgMBAAGjgfMwgfAwEgYDVR0TAQH/BAgwBgEB/wIBATARBgNV
HSAECjAIMAYGBFUdIAAwOgYIKwYBBQUHAQEELjAsMCoGCCsGAQUFBzABhh5odHRw
Oi8vb2NzcC5xdW92YWRpc2dsb2JhbC5jb20wDgYDVR0PAQH/BAQDAgEGMB8GA1Ud
IwQYMBaAFO3nb3Zav2DsSVvGpXe7chZxm8Q9MDsGA1UdHwQ0MDIwMKAuoCyGKmh0
dHA6Ly9jcmwucXVvdmFkaXNnbG9iYWwuY29tL3F2cmNhMmczLmNybDAdBgNVHQ4E
FgQUsxKJtalLNbwVAPCA6dh4h/ETfHYwDQYJKoZIhvcNAQELBQADggIBAFGm1Fqp
RMiKr7a6h707M+km36PVXZnX1NZocCn36MrfRvphotbOCDm+GmRkar9ZMGhc8c/A
Vn7JSCjwF9jNOFIOUyNLq0w4luk+Pt2YFDbgF8IDdx53xIo8Gv05e9xpTvQYaIto
qeHbQjGXfSGc91olfX6JUwZlxxbhdJH+rxTFAg0jcbqToJoScWTfXSr1QRcNbSTs
Y4CPG6oULsnhVvrzgldGSK+DxFi2OKcDsOKkV7W4IGg8Do2L/M588AfBnV8ERzpl
qgMBBQxC2+0N6RdFHbmZt0HQE/NIg1s0xcjGx1XW3YTOfje31rmAXKHOehm4Bu48
gr8gePq5cdQ2W9tA0Dnytb9wzH2SyPPIXRI7yNxaX9H8wYeDeeiKSSmQtfh1v5cV
7RXvm8F6hLJkkco/HOW3dAUwZFcKsUH+1eUJKLN18eDGwB8yGawjHvOKqcfg5Lf/
TvC7hgcx7pDYaCCaqHaekgUwXbB2Enzqr1fdwoU1c01W5YuQAtAx5wk1bf34Yq/J
ph7wNXGvo88N0/EfP9AdVGmJzy7VuRXeVAOyjKAIeADMlwpjBRhcbs9m3dkqvoMb
SXKJxv/hFmNgEOvOlaFsXX1dbKg1v+C1AzKAFdiuAIa62JzASiEhigqNSdqdTsOh
8W8hdONuKKpe9zKedhBFAvuxhDgKmnySglYc
-----END CERTIFICATE-----
EOF

#update trust
update-ca-certificates

