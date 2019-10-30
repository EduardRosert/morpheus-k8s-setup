#!/bin/bash
# Disables ipv6 on all interfaces in CentOS 7

# fail fast and show errors
set -eux

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1