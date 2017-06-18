#!/bin/bash

# Docker doesn't like coming back up from a halted vm, so restart it.
echo "Restarting Docker..."
sudo restart docker >/dev/null

# wait (maximum of 6 times, with an interval of 10 seconds for a total of 60 seconds) for nomad to be up.
echo "Waiting for 'nomad' to start..."
sleep 5
for i in {1..10}
do
  echo "Waiting for 'nomad' to start..."
  if nomad status 2>/dev/null ; then
    break
  else
    echo "Nomad not started yet, waiting..."
    sleep 5
  fi
done

eth_ip=$(/sbin/ifconfig enp0s8 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

cat << EOF

The Vagrant Hashistack contains the following components:

Consul - https://www.consul.io/

The consul UI is available at: http://$eth_ip:8500

$(consul members)

=========================================================

Nomad - https://www.nomadproject.io/

$(nomad server-members)

=========================================================

Vault - https://www.vaultproject.io/

Please see the Vault tmux tab (tab 2) for the unseal and root tokens
To use the 'vault' CLI, set the vault environment with:

'$ export VAULT_ADDR='http://127.0.0.1:8200'

=========================================================

Fabio - https://github.com/eBay/fabio

The Fabio UI is available at: http://$eth_ip:9998

=========================================================

Nomad UI - https://github.com/iverberk/nomad-ui

To start nomad-ui execute the following:

'$ nomad run nomad-ui.nomad'

then once the nomad-ui job is running (check with 'nomad status nomad-ui')
you can navigate to: http://nomad-ui.hashistack.vagrant

=========================================================

Vault UI - https://github.com/djenriquez/vault-ui

To start vault-ui execute the following:

'$ nomad run vault-ui.nomad'

then once the vault-ui job is running (check with 'nomad status vault-ui')
you can navigate to: http://vault-ui.hashistack.vagrant

=========================================================

To disconnect from the tmux session hit 'Cntrl + b' and 'd'.
To reconnect execute 'tmux a'

EOF
