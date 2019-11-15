#!/bin/bash
# Source: https://github.com/EduardRosert/morpheus-k8s-setup
# Morpheus Task
# Name: Disable ipv6
# Type: Remote Shell Script

# Disables ipv6 on all interfaces in CentOS 7/Ubuntu

# fail fast and show errors
set -eux

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1