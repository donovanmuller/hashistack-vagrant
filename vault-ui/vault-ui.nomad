job "vault-ui" {
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

	group "vault-ui" {

		restart {
			attempts = 10
			interval = "5m"
			delay = "25s"
			mode = "delay"
		}

		task "vault-ui" {
			driver = "docker"

			config {
				image = "djenriquez/vault-ui:latest"
				port_map {
					http = 8000
				}
			}

			service {
				name = "vault-ui"
				tags = ["urlprefix-vault-ui.hashistack.vagrant/"]
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
				NODE_TLS_REJECT_UNAUTHORIZED = "0"
			}

			resources {
				cpu = 500
				memory = 256
				network {
					mbits = 10
					port "http" {
						static = 8010
					}
				}
			}
		}
	}
}
