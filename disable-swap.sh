#!/bin/bash

set -eux

grep -v swap /etc/fstab > /tmp/x
mv /tmp/x /etc/fstab

swapoff /dev/vda2 || true
