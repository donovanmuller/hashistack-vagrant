#!/bin/bash

# Start Consul in dev mode with UI.
# The `advertise` address will default to the IP address assigned to the `eth0` interface.
# DNS interface is available on port 53 (default DNS port) so we can reference it from `/etc/resolv.conf`

sudo consul agent \
  -dev \
  -ui \
  --data-dir=/opt/consul \
  --advertise=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}') \
  --client=0.0.0.0 --dns-port=53
