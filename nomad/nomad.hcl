# Name the region, if omitted, the default "global" region will be used.
region = "vagrant"

# Persist data to a location that will survive a machine reboot.
data_dir = "/opt/nomad/"

# Bind to all addresses so that the Nomad agent is available both on loopback
# and externally.
bind_addr = "0.0.0.0"

# Advertise an accessible IP address so the server is reachable by other servers
# and clients. The IPs can be materialized by Terraform or be replaced by an
# init script.
advertise {
    http = "172.16.0.2:4646"
    rpc = "172.16.0.2:4647"
    serf = "172.16.0.2:4648"
}

# Enable debug endpoints.
enable_debug = true

client {
  enabled = true
  # Allow the Nomad client to be accessed from Docker containers.
  network_interface = "enp0s8"
  options {
    # Do not remove Docker images on stopping jobs. Avoids wasting bandwidth pulling images.
    docker.cleanup.image = false
  }
}
