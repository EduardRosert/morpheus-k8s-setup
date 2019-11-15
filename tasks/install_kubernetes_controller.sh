#!/bin/bash
# Source: https://github.com/EduardRosert/morpheus-k8s-setup
# Morpheus Task
# Name: Install Kubernetes Controller
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

# Installs Kubernetes Controller software
git clone https://github.com/EduardRosert/morpheus-k8s-setup.git
cd morpheus-k8s-setup

# Check the os and switch to the right branch
if [  -n "$(uname -a | grep Ubuntu)" ]; then
    git checkout ubuntu # Ubuntu
else
    git checkout master # CentOS
fi 


make install-requirements-controller