job "nomad-ui" {
	region = "vagrant"

	datacenters = ["dc1"]

	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}

	update {
		stagger = "10s"
		max_parallel = 1
	}

	group "nomad-ui" {

		restart {
			attempts = 10
			interval = "5m"
			delay = "25s"
			mode = "delay"
		}

		task "nomad-ui" {
			driver = "docker"

			config {
				image = "jippi/hashi-ui:latest"
				port_map {
					http = 3000
				}
			}

			service {
				name = "nomad-ui"
				tags = ["urlprefix-nomad-ui.hashistack.vagrant/"]
				port = "http"
				check {
					name = "alive"
					type = "http"
					interval = "10s"
					timeout = "2s"
					path = "/"
					protocol = "http"
				}
			}

			env {
				NOMAD_ENABLE = 1
				NOMAD_ADDR = "http://nomad.service.consul:4646"
				CONSUL_ENABLE = 1
				CONSUL_ADDR = "172.16.0.2:8500"
			}

			resources {
				cpu = 500
				memory = 256
				network {
					mbits = 10
					port "http" {
						static = 8000
					}
				}
			}
		}
	}
}
