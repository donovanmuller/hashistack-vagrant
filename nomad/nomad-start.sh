#!/bin/bash

# Start Nomad in dev mode.
# See `default.hcl` for configuration.

sudo nomad agent \
  -dev \
  -config nomad.hcl
