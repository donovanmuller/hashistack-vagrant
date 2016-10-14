#!/bin/bash

# Start Fabio load balancer.
# See `fabio.properties` for configuration details.

sudo fabio -cfg /etc/fabio.d/fabio.properties
