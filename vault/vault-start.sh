#!/bin/bash

# Start Vault in dev mode.
# See `default.hcl` for configuration.

sudo vault server \
  -dev \
  -dev-root-token-id="hashistack"
  -config vault.hcl
