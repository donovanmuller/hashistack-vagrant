# Hashistack Vagrant

A Vagrant managed VM based on the [demo Vagrantfile](https://raw.githubusercontent.com/hashicorp/nomad/master/demo/vagrant/Vagrantfile)
used in the [Getting Started](https://www.nomadproject.io/intro/getting-started/install.html)
guide for the [Nomad](https://www.nomadproject.io) project, which adds [Consul](https://www.consul.io/),
[Vault](https://www.vaultproject.io/),
[Fabio](https://github.com/eBay/fabio) load balancer, [Nomad UI](https://github.com/iverberk/nomad-ui)
and [Vault UI](https://github.com/djenriquez/vault-ui) to form a minimal implementation of a
["Hashistack"](https://twitter.com/hashtag/hashistack) for local development purposes.

## Quickstart

```bash
$ git clone https://github.com/donovanmuller/hashistack-vagrant.git
$ vagrant plugin install landrush
$ vagrant up
$ vagrant ssh

...

vagrant@hashistack:~$ tmuxp load full-hashistack.yml

...

vagrant@hashistack:~$ nomad init # following https://www.nomadproject.io/intro/getting-started/jobs.html
vagrant@hashistack:~$ nomad run nomad-ui.nomad
==> Monitoring evaluation "1aa7fe03"
    Evaluation triggered by job "nomad-ui"
    Allocation "72181329" created: node "ac32b972", group "nomad-ui"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "1aa7fe03" finished with status "complete"
vagrant@hashistack:~$ nomad status nomad-ui
ID          = nomad-ui
Name        = nomad-ui
Type        = service
Priority    = 50
Datacenters = dc1
Status      = running
Periodic    = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
nomad-ui    0       0         1        0       0         0

Allocations
ID        Eval ID   Node ID   Task Group  Desired  Status   Created At
72181329  1aa7fe03  ac32b972  nomad-ui    run      running  10/14/16 08:17:10 UTC
vagrant@hashistack:~$
```

then in your browser, go to: http://nomad-ui.hashistack.vagrant/

## Usage

The following sections describe the steps to use the Vagrant Hashistack:

### Clone the `hashistack-vagrant` project

Get the `Vagrantfile` and accompanying files and scripts by cloning this GitHub repository to your local machine:

```bash
$ git clone https://github.com/donovanmuller/hashistack-vagrant.git
```

### Provisioning the Hashistack VM

#### Vagrant prerequisites

It goes without saying that you should have [Vagrant](https://www.vagrantup.com/docs/getting-started/) installed.
The stack also requires the [Landrush plugin](https://github.com/vagrant-landrush/landrush) for DNS.
You can install it with:

```bash
$ vagrant plugin install landrush
```

#### Create and provision

Create and provision the Hashistack VM with Vagrant by running `vagrant up` in the root of the cloned project:

 ```bash
 $ # git clone https://github.com/donovanmuller/hashistack-vagrant.git
 $ cd hashistack-vagrant
 $ vagrant up
 ```

This will take a moment as it downloads and installs the following components:

* Consul - [0.8.4](https://www.consul.io/downloads.html)
* Nomad - [0.5.6](https://www.nomadproject.io/downloads.html)
* Vault - [0.7.3](https://www.vaultproject.io/downloads.html)
* Fabio - [1.5.0](https://github.com/eBay/fabio/releases/tag/v1.3.3)
* tmux/tmuxp - [1.2.1](https://github.com/tony/tmuxp)
* Docker
* Java 8 - OpenJDK 8

#### DNS with Landrush

The Landrush plugin is used to provide DNS resolution for the Hashistack
domain, `hashistack.vagrant`.

##### Fabio

The main use for this is exposing services via Fabio.
This allows the `hashistack.vagrant` domain to be used as a wildcard domain, so that all
exposed services can be resolved via DNS queries, for example `my-app.hashistack.vagrant`.
Assuming that `my-app` has a route entry configured in Fabio.

### Working with the Hashistack

Once the Hashistack has been provisioned, you can start the components by first opening a SSH session with:

```bash
$ vagrant ssh
```

#### Tmux

Then as the `motd` banner suggests, start a `tmux` session with:

```bash
$ tmuxp load full-hashistack.yml
```

This will open 5 windows, each window containing the following:

* Window 0 (`consul`) - Start Consul agent in development mode.
* Window 1 (`nomad`) - Start Nomad in development mode as server and client
* Window 2 (`vault`) - Start Vault in development mode as server
* Window 3 (`fabio`) - Start Fabio configured to connect to Consul on Window 1
* Window 4 (`start`) - A shell session that you can use to work with the [Nomad CLI](https://www.nomadproject.io/docs/commands/index.html) etc.

Window 4 (`start`) will focus on start and presents you with an overview of the components running in the stack:

For more commands available when using tmux, please see [this cheatsheet](https://gist.github.com/MohamedAlaa/2961058) .

![Hashistack in tmux session](/docs/images/hashistack-vagrant.png)

You can now schedule jobs using `nomad`.

#### Service discovery

With Consul serving as a DNS server (on the default DNS port: `53`) for the VM,
you can use the [DNS interface](https://www.consul.io/docs/agent/dns.html) to resolve
services registered with Consul. This includes Nomad via `nomad-client` etc.

The search domain `service.consul` is configured so you do not have to use the fully qualified
name of `nomad-cient.service.consul` but rather use the shortened `nomad-clent` form:

```bash
$ ping -c 1 nomad-client
```

#### Docker

Docker is installed so you can use the [`docker` task driver](https://www.nomadproject.io/docs/drivers/docker.html)
to schedule tasks.

##### Service discovery

The configuration to use Consul as a DNS server has already been done.
This means you can refer to Consul registered services from within your containers as you would on the VM:

```bash
$ docker run --rm aanand/docker-dnsutils dig nomad-client +search
```

### Nomad UI

[Nomad UI](https://github.com/iverberk/nomad-ui) is valuable as a quick glance into Nomad via a web interface.

Nomad UI is run as a Nomad job, where the `nomad-ui/nomad-ui.nomad` job definition file is included
in this project. To schedule the `nomad-ui` job:

```bash
$ nomad run nomad-ui.nomad
```

wait until it's running and then is should be available on:

http://nomad-ui.hashistack.vagrant

note the URL uses the `hashistack.vagrant` domain, as the Nomad UI is routed via Fabio (check `nomad-ui/nomad-ui.nomad` for details).

### Vault UI

[Vault UI](https://github.com/djenriquez/vault-ui) is valuable as a quick glance into Vault via a web interface.

Vault UI is run as a Nomad job, where the `vault-ui/vault-ui.nomad` job definition file is included
in this project. To schedule the `vault-ui` job:

```bash
$ nomad run vault-ui.nomad
```

wait until it's running and then is should be available on:

http://vault-ui.hashistack.vagrant

note the URL uses the `hashistack.vagrant` domain, as the Nomad UI is routed via Fabio (check `vault-ui/vault-ui.nomad` for details).
