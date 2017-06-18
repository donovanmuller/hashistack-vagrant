#!/usr/bin/env bash

echo Configuring DNS resolution...

# The below configuration will get overwritten if `sudo resolvconf -u` is run
# Tried putting it in `/etc/resolvconf/resolv.conf.d/base` but it does not get added at the top
# which results in Consul never being used for DNS queries.
sudo tee /etc/resolv.conf << EOF
nameserver `/sbin/ifconfig enp0s8 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
nameserver 8.8.8.8
search service.consul
EOF
