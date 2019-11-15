#!/bin/bash
# Source: https://github.com/EduardRosert/morpheus-k8s-setup
# Morpheus Task
# Name: Install Kubernetes Worker
# Type: Remote Shell Script

# Install requirements
if [  -n "$(uname -a | grep Ubuntu)" ]; then
    # Ubuntu
    echo "Ubuntu: installing git and make" 
    apt-get install git make -y
else
    # CentOS
    echo "CentOS: git and make should be available" 
fi 

# Installs Kubernetes Worker software
export KUBE_API_ADDRESS=#<your controller ip goes here>

git clone https://github.com/EduardRosert/morpheus-k8s-setup.git
cd morpheus-k8s-setup
make install-requirements-worker